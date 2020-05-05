defmodule State.ContentListenerWorker do
  use GenServer

  defstruct pending_events: [],
            batch_size: 10

  def start_link(_), do: GenServer.start_link(__MODULE__, [], name: __MODULE__)

  @impl true
  def init(_) do
    {:ok, %__MODULE__{}, {:continue, :continue_init}}
  end

  @impl true
  def handle_continue(:continue_init, state) do
    Geneity.PubSub.subscribe_new_events()
    {:noreply, state}
  end

  @impl true
  def handle_info({:new_events, {operator_id, event_ids}}, state) do
    pending =
      event_ids
      |> Enum.map(fn id -> {operator_id, id} end)

    state =
      if state.pending_events == [] do
        # kick off handling of pending events
        handle_pending()
        %{state | pending_events: pending}
      else
        # order is not preserved but shouldn't matter too much
        %{state | pending_events: List.flatten([pending | state.pending_events])}
      end

    {:noreply, state}
  end

  def handle_info(:handle_pending, %{pending_events: []} = state) do
    {:noreply, state}
  end

  def handle_info(:handle_pending, state) do
    {items, rest} = Enum.split(state.pending_events, state.batch_size)

    for {operator_id, event_id} <- items do
      State.EventSupervisor.start_child(event_id, operator_id)
    end

    handle_pending(10)
    state = %{state | pending_events: rest}
    {:noreply, state}
  end

  defp handle_pending(timeout \\ 0), do: Process.send_after(self(), :handle_pending, timeout)
end
