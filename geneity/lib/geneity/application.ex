defmodule Geneity.Application do
  use Application

  @impl true
  def start(_, _) do
    config = Freshness.Config.new(:geneity, 10, :http, "varnishcontapi.stoiximan.eu", 80, [])

    children = [
      {Registry, keys: :unique, name: Freshness.Config.registry_name()},
      {Freshness.Supervisor, config}
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
