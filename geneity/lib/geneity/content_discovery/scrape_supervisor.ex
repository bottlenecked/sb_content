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

  def children() do
    __MODULE__
    |> DynamicSupervisor.which_children()
    |> Enum.map(fn {_, pid, _, _} -> pid end)
    |> Enum.filter(&is_pid/1)
  end

  def start_child(operator_id, :pre) do
    do_start_child(operator_id, :pre, 60_000)
  end

  def start_child(operator_id, :live) do
    do_start_child(operator_id, :live, 5_000)
  end

  defp do_start_child(operator_id, type, interval) when is_operator(operator_id) do
    args = %{type: type, operator_id: operator_id, interval: interval}
    DynamicSupervisor.start_child(__MODULE__, {ScrapeWorker, args})
  end

  def stop_child(operator_id, type) when is_operator(operator_id) and type in [:live, :pre] do
    case Registry.lookup(GeneityRegistry, ScrapeWorker.name(type, operator_id)) do
      [{pid, _value}] ->
        DynamicSupervisor.terminate_child(__MODULE__, pid)

      _other ->
        {:error, :not_found}
    end
  end
end
