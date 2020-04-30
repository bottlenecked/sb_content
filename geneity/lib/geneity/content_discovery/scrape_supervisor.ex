defmodule Geneity.ContentDiscovery.ScrapeSupervisor do
  use Supervisor

  def start_link(_) do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    Geneity.Api.Operator.all()
    |> Enum.map(fn operator_id ->
      Supervisor.child_spec({Geneity.ContentDiscovery.ScrapeWorker, operator_id},
        id: operator_id
      )
    end)
    |> Supervisor.init(strategy: :one_for_one)
  end
end
