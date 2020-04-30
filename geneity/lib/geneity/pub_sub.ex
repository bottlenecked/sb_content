defmodule Geneity.PubSub do
  @doc """
  Subscribe to receive notification when new events are discovered. The receiving process
  will receive messages of the form {:new_events, {operator_id, [event_ids]}}. These events might
  not always be 'new' so further checks should be made that they are indeed new.
  """
  def subscribe_new_events() do
    Registry.register(name(), :new_events, [])

    get_events = &Geneity.ContentDiscovery.ScrapeWorker.get_current_event_ids/1

    Geneity.Api.Operator.all()
    |> Enum.map(fn operator_id -> {operator_id, get_events.(operator_id)} end)
    |> Enum.each(fn {operator_id, event_ids} -> publish_new_events(operator_id, event_ids) end)
  end

  def publish_new_events(operator_id, event_ids) do
    Registry.dispatch(name(), :new_events, fn entries ->
      for {pid, _} <- entries, do: send(pid, {:new_events, {operator_id, event_ids}})
    end)
  end

  def name(), do: __MODULE__
end
