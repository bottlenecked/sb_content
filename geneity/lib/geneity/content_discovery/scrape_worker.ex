defmodule Geneity.ContentDiscovery.ScrapeWorker do
  use GenServer
  require Logger

  alias Geneity.ContentDiscovery

  defstruct [
    :operator_id,
    :live_interval,
    :regular_interval
  ]

  def start_link(operator_id) do
    args = %__MODULE__{
      operator_id: operator_id,
      live_interval: 5_000,
      regular_interval: 60_000
    }

    GenServer.start_link(__MODULE__, args, name: via_tuple(operator_id))
  end

  @impl true
  def init(state) do
    schedule_next_scrape(Utils.Jitter.between(0, 150), :scrape_live)
    schedule_next_scrape(Utils.Jitter.between(0, 150), :scrape_pre)
    {:ok, state}
  end

  @impl true
  def handle_info(:scrape_live = type, state) do
    state.operator_id
    |> ContentDiscovery.scrape_live()
    |> handle_scrape_results(state.operator_id)

    state.live_interval
    |> Utils.Jitter.jitter(200)
    |> schedule_next_scrape(type)

    {:noreply, state}
  end

  @impl true
  def handle_info(:scrape_pre = type, state) do
    state.operator_id
    |> ContentDiscovery.scrape()
    |> handle_scrape_results(state.operator_id)

    state.regular_interval
    |> Utils.Jitter.jitter(200)
    |> schedule_next_scrape(type)

    {:noreply, state}
  end

  defp handle_scrape_results(results, operator_id) do
    results
    |> log_errors(operator_id)
    |> publish_event_ids(operator_id)
  end

  defp log_errors(%ContentDiscovery{} = result, operator_id) do
    if result.error do
      Logger.error("Error fetching content for operator #{operator_id}: #{inspect(result.error)}")
    end

    if result.failed_sport_lookups != [] do
      result.failed_sport_lookups
      |> Enum.each(fn {sport_id, error} ->
        Logger.error(
          "Error fetching leagues for sport [#{operator_id}.#{sport_id}]: #{inspect(error)}"
        )
      end)
    end

    if result.failed_league_lookups != [] do
      result.failed_league_lookups
      |> Enum.each(fn {league_id, error} ->
        Logger.error(
          "Error fetching events for league [#{operator_id}.#{league_id}]: #{inspect(error)}"
        )
      end)
    end

    result
  end

  defp publish_event_ids(%ContentDiscovery{event_ids: event_ids}, operator_id) do
    IO.inspect(operator: operator_id, events: event_ids)
  end

  @spec schedule_next_scrape(non_neg_integer(), :scrape_pre | :scrape_live) :: reference()
  defp schedule_next_scrape(millis_after, type),
    do: Process.send_after(self(), type, millis_after)

  defp via_tuple(operator_id) do
    {:via, Registry, {GeneityRegistry, {:scaper, operator_id}}}
  end
end
