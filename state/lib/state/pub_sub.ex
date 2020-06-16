defmodule State.PubSub do
  def name(), do: __MODULE__

  @doc """
  Subscribe a process to state changes published by EventWorker gen_servers.
  The message received will look like `{:state_changes, {operator_id, list(change())}}`
  """
  def subscribe_to_changes() do
    Registry.register(name(), :state_changes, [])
  end

  def publish_changes(operator_id, changes) do
    Registry.dispatch(name(), :state_changes, fn entries ->
      for {pid, _} <- entries, do: send(pid, {:state_changes, {operator_id, changes}})
    end)
  end
end
