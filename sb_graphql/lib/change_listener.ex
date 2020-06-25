defmodule SbGraphql.ChangeListener do
  @moduledoc """
  This genserver listens for published diffs from the state servers and publishes them to GraphQL subscribers
  """
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_) do
    State.PubSub.subscribe_to_changes()
    {:ok, []}
  end

  @impl true
  def handle_info({:state_changes, {operator_id, changes}}, state) do
    publish(changes, operator_id)
    {:noreply, state}
  end

  def publish(changes, operator_id) do
    changes
    |> Enum.group_by(fn change -> change.event_id end)
    # use a little trick for subscribers interested in all events
    |> Map.put("*", changes)
    |> Enum.each(fn {event_id, ev_changes} ->
      Absinthe.Subscription.publish(SbApiWeb.Endpoint, ev_changes,
        changes: "#{operator_id}/#{event_id}"
      )
    end)
  end
end
