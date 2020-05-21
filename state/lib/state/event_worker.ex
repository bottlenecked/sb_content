defmodule State.EventWorker do
  use GenServer, restart: :transient

  alias State.{Content, Telemetry}

  require Logger

  defstruct [
    :event_id,
    :operator_id,
    :data,
    :last_polled_on,
    :last_successful_update_on,
    polling_interval_millis_live: 5000,
    polling_interval_millis_pre: 60000
  ]

  def start_link(config) do
    GenServer.start_link(__MODULE__, config, name: via_tuple(config.event_id, config.operator_id))
  end

  def registry_name(), do: EventServerRegistry

  def get_event_data(event_id, operator_id) do
    event_id
    |> via_tuple(operator_id)
    |> GenServer.call(:get_event_data)
  end

  @impl true
  def init(config) do
    Logger.metadata(event_id: config.event_id)

    state = %__MODULE__{
      event_id: config.event_id,
      operator_id: config.operator_id
    }

    {:ok, state, {:continue, :continue_init}}
  end

  @impl true
  def handle_continue(:continue_init, state) do
    Telemetry.register_sb_event(state.operator_id)

    loop(state)
  end

  @impl true
  def handle_call(:get_event_data, _from, state) do
    {:reply, state.data, state}
  end

  @impl true
  def handle_info(:poll, state) do
    loop(state)
  end

  # when freshness calls time out, we might get ghost replies later that we need to ignore
  @impl true
  def handle_info({ref, _}, state) when is_reference(ref), do: {:noreply, state}

  @impl true
  def terminate(_reason, state) do
    Telemetry.unregister_sb_event(state.operator_id)
    :ok
  end

  defp loop(state) do
    case do_work(state) do
      {:keep_polling, new_state, next_tick} ->
        schedule_next_poll(next_tick)
        {:noreply, new_state}

      :stop ->
        {:stop, :normal, state}
    end
  end

  defp do_work(state) do
    now = DateTime.utc_now()
    state = %{state | last_polled_on: now}

    with {:fetch, {:ok, new_data}} <- {:fetch, fetch_fresh(state)} do
      state = %{state | last_successful_update_on: now}
      changes = diff(state.data, new_data)
      publish_changes(changes, state.operator_id)
      set_tags(state, changes)
      state = %{state | data: new_data}
      next_poll = calculate_next_poll(state)
      {:keep_polling, state, next_poll}
    else
      {:fetch, {:error, :event_not_found}} ->
        publish_event_removed(state)
        Logger.debug("event not found, monitoring stopped")
        :stop

      {:fetch, {:error, reason}} ->
        Logger.error("event polling failed with reason: #{inspect(reason)}")
        # TODO: perhaps exponential backoff would be more appropriate here?
        {:keep_polling, state, 10_000}
    end
  end

  defp fetch_fresh(state), do: Content.get_event_data(state.event_id, state.operator_id)

  defp diff(old_data, new_data), do: DiffEngine.diff(old_data, new_data)

  defp publish_changes(changes, operator_id) do
    changes
    |> length()
    |> Telemetry.changes_count(operator_id)
  end

  defp set_tags(state, changes) do
    name = name(state.event_id, state.operator_id)
    Enum.each(changes, fn change -> State.Tags.tag(name, change) end)
  end

  defp publish_event_removed(state) do
    IO.inspect(event_removed: state.event_id)
  end

  defp calculate_next_poll(%__MODULE__{} = state) do
    interval =
      if live_now_or_close_enough?(state) do
        state.polling_interval_millis_live
      else
        state.polling_interval_millis_pre
      end

    # introduce a 5% jitter
    Utils.Jitter.jitter(interval, trunc(interval * 0.05))
  end

  defp schedule_next_poll(how_long) when is_integer(how_long) do
    Process.send_after(self(), :poll, how_long)
  end

  defp live_now_or_close_enough?(%{data: %{live?: true}}), do: true

  defp live_now_or_close_enough?(%{data: %{start_time: time}}) do
    now = DateTime.utc_now()
    DateTime.diff(time, now, :second) <= 120
  end

  defp live_now_or_close_enough?(_), do: false

  defp via_tuple(event_id, operator_id),
    do: {:via, Registry, {registry_name(), name(event_id, operator_id)}}

  defp name(event_id, operator_id), do: {:event, event_id, operator_id}
end
