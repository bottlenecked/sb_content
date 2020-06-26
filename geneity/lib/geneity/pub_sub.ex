defmodule Geneity.PubSub do
  alias Geneity.ContentDiscovery.{ScrapeSupervisor, ScrapeWorker}

  @doc """
  Subscribe to receive notification when new events are discovered. The receiving process
  will receive messages of the form {:new_events, {operator_id, [event_ids]}}. These events might
  not always be 'new' so further checks should be made that they are indeed new.
  """
  @spec subscribe_new_events() :: [{Geneity.Api.Operator.t(), [String.t()]}]
  def subscribe_new_events() do
    Registry.register(name(), :new_events, [])

    ScrapeSupervisor.children()
    |> Enum.map(&ScrapeWorker.get_current_event_ids/1)
  end

  def publish_new_events(operator_id, event_ids) do
    Registry.dispatch(name(), :new_events, fn entries ->
      for {pid, _} <- entries, do: send(pid, {:new_events, {operator_id, event_ids}})
    end)
  end

  def name(), do: __MODULE__
end
