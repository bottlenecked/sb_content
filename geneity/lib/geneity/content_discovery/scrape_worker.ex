defmodule Geneity.ContentDiscovery.ScrapeWorker do
  use GenServer
  require Logger

  alias Geneity.ContentDiscovery

  defstruct [
    :type,
    :operator_id,
    :interval,
    events: MapSet.new()
  ]

  @type milliseconds :: non_neg_integer()

  @type args :: %{
          type: :pre | :live,
          interval: milliseconds(),
          operator_id: Geneity.Api.Operator.t()
        }

  @spec start_link(args()) :: GenServer.on_start()
  def start_link(args) do
    args = %__MODULE__{
      type: args.type,
      operator_id: args.operator_id,
      interval: args.interval
    }

    GenServer.start_link(__MODULE__, args, name: via_tuple(args.type, args.operator_id))
  end

  @spec get_current_event_ids(pid()) :: {Geneity.Api.Operator.t(), [String.t()]}
  def get_current_event_ids(pid) do
    GenServer.call(pid, :get_event_ids)
  end

  @impl true
  def init(state) do
    Utils.Jitter.between(0, 150)
    |> schedule_next_scrape()

    {:ok, state}
  end

  @impl true
  def handle_call(:get_event_ids, _from, state) do
    event_ids =
      state.events
      |> MapSet.to_list()

    {:reply, {state.operator_id, event_ids}, state}
  end

  @impl true
  def handle_info(:scrape, state) do
    state =
      state.type
      |> do_scrape(state.operator_id)
      |> handle_scrape_results(state)

    state.interval
    |> Utils.Jitter.jitter(200)
    |> schedule_next_scrape()

    {:noreply, state}
  end

  # when freshness calls time out, we might get ghost replies later that we need to ignore
  @impl true
  def handle_info({ref, _}, state) when is_reference(ref), do: {:noreply, state}

  defp do_scrape(:pre, operator_id), do: ContentDiscovery.scrape(operator_id)
  defp do_scrape(:live, operator_id), do: ContentDiscovery.scrape_live(operator_id)

  defp handle_scrape_results(results, %{operator_id: operator_id} = state) do
    results
    |> log_errors(state.type, operator_id)
    |> search_for_possibly_new_event_ids(state)
    |> publish_possibly_new_event_ids(state.operator_id)

    update_state(results, state)
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
    |> Enum.filter(fn id -> !MapSet.member?(state.events, id) end)
  end

  defp publish_possibly_new_event_ids(new_event_ids, operator_id) do
    if new_event_ids != [] do
      Geneity.PubSub.publish_new_events(operator_id, new_event_ids)
    end
  end

  defp update_state(%ContentDiscovery{event_ids: event_ids, error: nil}, state),
    do: %{state | events: MapSet.new(event_ids)}

  # minor optimization to avoid too much publishing: do not update state if top-level request failed
  defp update_state(_, state),
    do: state

  @spec schedule_next_scrape(non_neg_integer()) :: reference()
  defp schedule_next_scrape(millis_after),
    do: Process.send_after(self(), :scrape, millis_after)

  defp via_tuple(type, operator_id) do
    {:via, Registry, {GeneityRegistry, name(type, operator_id)}}
  end

  def name(type, operator_id), do: {:scaper, {type, operator_id}}
end
