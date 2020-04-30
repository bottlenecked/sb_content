defmodule Geneity.ContentDiscovery.ScrapeWorker do
  use GenServer
  require Logger

  alias Geneity.ContentDiscovery

  defstruct [
    :operator_id,
    :live_interval,
    :regular_interval,
    live_events: MapSet.new(),
    pre_events: MapSet.new()
  ]

  def start_link(operator_id) do
    args = %__MODULE__{
      operator_id: operator_id,
      live_interval: 5_000,
      regular_interval: 60_000
    }

    GenServer.start_link(__MODULE__, args, name: via_tuple(operator_id))
  end

  def get_current_event_ids(operator_id) do
    name = via_tuple(operator_id)
    GenServer.call(name, :get_event_ids)
  end

  @impl true
  def init(state) do
    schedule_next_scrape(Utils.Jitter.between(0, 150), :scrape_live)
    schedule_next_scrape(Utils.Jitter.between(0, 150), :scrape_pre)
    {:ok, state}
  end

  @impl true
  def handle_call(:get_event_ids, _from, state) do
    result =
      [
        MapSet.to_list(state.live_events),
        MapSet.to_list(state.pre_events)
      ]
      |> List.flatten()
      |> Enum.uniq()

    {:reply, result, state}
  end

  @impl true
  def handle_info(scrape_type, state) do
    state =
      scrape_type
      |> do_scrape(state.operator_id)
      |> handle_scrape_results(scrape_type, state)

    state.live_interval
    |> Utils.Jitter.jitter(200)
    |> schedule_next_scrape(scrape_type)

    {:noreply, state}
  end

  defp do_scrape(:scrape_pre, operator_id), do: ContentDiscovery.scrape(operator_id)
  defp do_scrape(:scrape_live, operator_id), do: ContentDiscovery.scrape_live(operator_id)

  defp handle_scrape_results(results, type, %{operator_id: operator_id} = state) do
    results
    |> log_errors(type, operator_id)
    |> search_for_possibly_new_event_ids(state)
    |> publish_possibly_new_event_ids(state.operator_id)

    update_state(type, results, state)
  end

  defp log_errors(%ContentDiscovery{} = result, type, operator_id) do
    if result.error do
      Logger.error(
        "Error fetching #{type} content for operator #{operator_id}: #{inspect(result.error)}"
      )
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

  defp search_for_possibly_new_event_ids(%ContentDiscovery{event_ids: event_ids}, state) do
    # Note: we are searching for _possibly_ new events because previous poll might have encountered errors for some sports or leagues
    # and thus not return event ids. Since each polling round the result is stored, we might end up re-discovering new events
    # because in the new polling round we managed to scrape without errors
    event_ids
    |> Enum.filter(fn id -> !MapSet.member?(state.live_events, id) end)
    |> Enum.filter(fn id -> !MapSet.member?(state.pre_events, id) end)
  end

  defp publish_possibly_new_event_ids(new_event_ids, operator_id) do
    if new_event_ids != [] do
      Geneity.PubSub.publish_new_events(operator_id, new_event_ids)
    end
  end

  defp update_state(:scrape_live, %ContentDiscovery{event_ids: event_ids, error: nil}, state),
    do: %{state | live_events: MapSet.new(event_ids)}

  defp update_state(:scrape_pre, %ContentDiscovery{event_ids: event_ids, error: nil}, state),
    do: %{state | pre_events: MapSet.new(event_ids)}

  # minor optimization to avoid too much publishing: do not update state if top-level request failed
  defp update_state(_, _, state),
    do: state

  @spec schedule_next_scrape(non_neg_integer(), :scrape_pre | :scrape_live) :: reference()
  defp schedule_next_scrape(millis_after, type),
    do: Process.send_after(self(), type, millis_after)

  defp via_tuple(operator_id) do
    {:via, Registry, {GeneityRegistry, {:scaper, operator_id}}}
  end
end
