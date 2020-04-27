defmodule State.EventWorker do
  use GenServer, restart: :transient

  alias State.Content

  defstruct [
    :event_id,
    :operator_id,
    :data,
    :last_polled_on,
    :last_successful_update_on,
    polling_interval_millis: 5000
  ]

  def start_link(config) do
    GenServer.start_link(__MODULE__, config, name: via_tuple(config.event_id, config.operator_id))
  end

  def registry_name(), do: EventServerRegistry

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
    case do_work(state) do
      {:ok, new_state} ->
        schedule_next_poll(state)
        {:noreply, new_state}

      {:stop, reason} ->
        {:stop, reason, state}
    end
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

  defp do_work(state) do
    now = DateTime.utc_now()
    state = %{state | last_polled_on: now}

    with {:fetch, {:ok, new_data}} <- {:fetch, fetch_fresh(state)} do
      state = %{state | last_successful_update_on: now}
      changes = diff(state.data, new_data)
      publish_changes(changes)
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

  defp publish_changes(changes) do
    IO.inspect(changes: changes)
  end

  defp publish_event_removed(state) do
    IO.inspect(event_removed: state.event_id)
  end

  defp schedule_next_poll(state) do
    next_tick = state.polling_interval_millis + jitter_millis(-200, 200)
    IO.inspect(next_tick: next_tick)
    Process.send_after(self(), :poll, next_tick)
  end

  defp jitter_millis(min, max) do
    rnd =
      (max - min)
      |> abs()
      |> :rand.uniform()

    min + rnd - 1
  end

  defp via_tuple(event_id, operator_id),
    do: {:via, Registry, {registry_name(), {:event, event_id, operator_id}}}
end
