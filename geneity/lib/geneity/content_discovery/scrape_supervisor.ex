defmodule Geneity.ContentDiscovery.ScrapeSupervisor do
  use DynamicSupervisor

  import Geneity.Api.Operator, only: [is_operator: 1]
  alias Geneity.ContentDiscovery.ScrapeWorker

  def start_link(_) do
    DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def scrapers_list() do
    __MODULE__
    |> DynamicSupervisor.which_children()
    |> Enum.map(fn {_, pid, _, _} -> pid end)
  end

  def start_scraper(operator_id, :pre) do
    do_start_scraper(operator_id, :pre, 60_000)
  end

  def start_scraper(operator_id, :live) do
    do_start_scraper(operator_id, :live, 5_000)
  end

  defp do_start_scraper(operator_id, type, interval) when is_operator(operator_id) do
    spec = {ScrapeWorker, %{type: type, interval: interval, operator_id: operator_id}}
    DynamicSupervisor.start_child(__MODULE__, spec)
  end
end
