defmodule Geneity.Application do
  use Application

  @impl true
  def start(_, _) do
    config = Freshness.Config.new(:geneity, 20, :http, "varnishcontapi.stoiximan.eu", 80, [])

    children = [
      Supervisor.child_spec({Registry, keys: :unique, name: Freshness.Config.registry_name()},
        id: Freshness.Config.registry_name()
      ),
      Supervisor.child_spec({Registry, keys: :unique, name: GeneityRegistry},
        id: GeneityRegistry
      ),
      {Freshness.Supervisor, config},
      Geneity.ContentDiscovery.ScrapeSupervisor
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
