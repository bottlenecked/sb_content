defmodule State.EventWorker do
  use GenServer, restart: :transient

  alias State.{Content, Telemetry}

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
    state = %__MODULE__{
      event_id: config.event_id,
      operator_id: config.operator_id
    }

    {:ok, state, {:continue, :continue_init}}
  end

  @impl true
  def handle_continue(:continue_init, state) do
    Telemetry.register_sb_event(state.operator_id)

    case do_work(state) do
      {:ok, new_state} ->
        schedule_next_poll(state)
        {:noreply, new_state}

      {:stop, reason} ->
        {:stop, reason, state}
    end
  end

  @impl true
  def handle_call(:get_event_data, _from, state) do
    {:reply, state.data, state}
  end

  @impl true
  def handle_info(:poll, state) do
    case do_work(state) do
      {:ok, new_state} ->
        schedule_next_poll(state)
        {:noreply, new_state}

      {:stop, reason} ->
        {:stop, reason, state}
    end
  end

  # when freshness calls time out, we might get ghost replies later that we need to ignore
  @impl true
  def handle_info({ref, _}, state) when is_reference(ref), do: {:noreply, state}

  @impl true
  def terminate(_reason, state) do
    Telemetry.unregister_sb_event(state.operator_id)
    :ok
  end

  defp do_work(state) do
    now = DateTime.utc_now()
    state = %{state | last_polled_on: now}

    with {:fetch, {:ok, new_data}} <- {:fetch, fetch_fresh(state)} do
      state = %{state | last_successful_update_on: now}
      changes = diff(state.data, new_data)
      publish_changes(changes, state.operator_id)
      {:ok, %{state | data: new_data}}
    else
      {:fetch, {:error, :event_not_found}} ->
        publish_event_removed(state)
        {:stop, :normal}

      {:fetch, {:error, %{reason: :closed}}} ->
        do_work(state)

      {:fetch, {:error, reason}} ->
        IO.inspect(error: reason)
        # todo: log error
        {:ok, state}
    end
  end

  defp fetch_fresh(state), do: Content.get_event_data(state.event_id, state.operator_id)

  defp diff(old_data, new_data), do: DiffEngine.diff(old_data, new_data)

  defp publish_changes(changes, operator_id) do
    changes
    |> length()
    |> Telemetry.changes_count(operator_id)
  end

  defp publish_event_removed(state) do
    IO.inspect(event_removed: state.event_id)
  end

  defp schedule_next_poll(state) do
    interval =
      if live_now_or_close_enough?(state) do
        state.polling_interval_millis_live
      else
        state.polling_interval_millis_pre
      end

    next_tick = Utils.Jitter.jitter(interval, 200)
    Process.send_after(self(), :poll, next_tick)
  end

  defp live_now_or_close_enough?(%{data: %{live?: true}}), do: true

  defp live_now_or_close_enough?(%{data: %{start_time: time}}) do
    now = DateTime.utc_now()
    DateTime.diff(time, now, :second) <= 120
  end

  defp live_now_or_close_enough?(_), do: false

  defp via_tuple(event_id, operator_id),
    do: {:via, Registry, {registry_name(), {:event, event_id, operator_id}}}
end
