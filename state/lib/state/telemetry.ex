defmodule State.Telemetry do
  use Supervisor
  import Telemetry.Metrics

  @table __MODULE__

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    :ets.new(@table, [:set, :public, :named_table])

    children = [
      {:telemetry_poller, measurements: periodic_measurements(), period: 10_000}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  def metrics do
    # this function is called in the dashboard reporter of SbApi
    [
      summary("connections.http.geneity"),
      last_value("state.events.total", tags: [:operator]),
      summary("state.diffs.count", tags: [:operator])
    ]
  end

  defp periodic_measurements do
    [
      {__MODULE__, :open_connections, []},
      {__MODULE__, :events_total, []}
    ]
  end

  def open_connections() do
    count = Freshness.Debug.connection_count(:geneity)
    :telemetry.execute([:connections, :http], %{geneity: count})
  end

  def events_total() do
    :ets.match(@table, {{:events, :"$1"}, :"$2"})
    |> Enum.each(fn [operator_id, count] ->
      :telemetry.execute([:state, :events], %{total: count}, %{operator: operator_id})
    end)
  end

  def changes_count(count, operator_id) do
    :telemetry.execute([:state, :diffs], %{count: count}, %{operator: operator_id})
  end

  def register_sb_event(operator_id) do
    :ets.update_counter(@table, {:events, operator_id}, 1, {1, 0})
  end

  def unregister_sb_event(operator_id) do
    :ets.update_counter(@table, {:events, operator_id}, -1, {1, 0})
  end
end
