defmodule Geneity.ContentDiscovery do
  alias Geneity.Api
  alias Geneity.Api.Operator

  @typedoc """
  error: error that prevented continuation of scraping, e.g. failed to get the sport list
  event_ids: a list of event_ids we managed to successfully retrieve
  league_ids: a list of league_ids we managed to successfully retrieve
  failed_sport_lookups: contains a list of {sport_id, reason} tuples for sports that league lookup failed
  failed_league_lookups: contains a list of {league_id, reason} tuples for leagues that event lookup failed
  """
  @type t() :: %__MODULE__{}

  defstruct [
    :error,
    event_ids: [],
    league_ids: [],
    failed_sport_lookups: [],
    failed_league_lookups: []
  ]

  @doc """
  Scans for event ids that are now live or are about to start. Intended to
  be called more often than scrape, because some events are only ever offered live
  and are not discoverable during pre-event scrapping
  """
  @spec scrape(Operator.t()) :: t()
  def scrape_live(operator_id \\ Operator.stoiximan_gr()) do
    case Api.get_live_event_ids(operator_id) do
      {:ok, event_ids} ->
        %__MODULE__{
          event_ids: event_ids
        }

      {:error, error} ->
        %__MODULE__{
          error: error
        }
    end
  end

  @doc """
  Returns aggregated scrapping results from scrapping geneity. This involves issueing multiple
  requests that may fail, so we gather both successful and failed intermediate results.

  A note: instead of gathering failed results, we could have logged them here instead- but that would
  make a mess out of our code because:
  1) we'd introduce logging as a concern in what is otherwise pure-y logic
  2) by using a specific logging lib we could be forcing our decision on users of our lib
  3) Should we need to do other actions on failure (e.g. retry the requests) we'd either need to also
     tackle this concern here or strip the caller of the ability to do that- both bad options.
  """
  @spec scrape(Operator.t()) :: t()
  def scrape(operator_id \\ Operator.stoiximan_gr()) do
    case Api.get_sport_ids(operator_id) do
      {:ok, sport_ids} ->
        do_scrape(sport_ids, operator_id)

      {:error, reason} ->
        %__MODULE__{
          error: reason
        }
    end
  end

  defp do_scrape(sport_ids, operator_id) do
    sport_ids
    |> scrape_for_leagues(operator_id)
    |> scrape_for_events(operator_id)
  end

  defp scrape_for_leagues(sport_ids, operator_id) do
    result =
      sport_ids
      |> Task.async_stream(fn sport_id -> Api.get_league_ids_for_sport(sport_id, operator_id) end,
        max_concurrency: 8
      )
      |> Enum.zip(sport_ids)
      |> Enum.reduce(%__MODULE__{}, &reduce_sport_result/2)

    %{result | league_ids: List.flatten(result.league_ids)}
  end

  defp scrape_for_events(result, operator_id) do
    result =
      result.league_ids
      |> Task.async_stream(
        fn league_id -> Api.get_event_ids_for_league(league_id, operator_id) end,
        max_concurrency: 8
      )
      |> Enum.zip(result.league_ids)
      |> Enum.reduce(result, &reduce_league_result/2)

    %{result | event_ids: List.flatten(result.event_ids)}
  end

  defp reduce_sport_result({{:ok, {:ok, league_ids}}, _sport_id}, acc) do
    %{acc | league_ids: [acc.league_ids, league_ids]}
  end

  defp reduce_sport_result({{:error, reason}, sport_id}, acc) do
    # when the task has failed
    %{acc | failed_sport_lookups: [{sport_id, reason} | acc.failed_sport_lookups]}
  end

  defp reduce_sport_result({{:ok, {:error, reason}}, sport_id}, acc) do
    # when task succeeded but request returned an error
    %{acc | failed_sport_lookups: [{sport_id, reason} | acc.failed_sport_lookups]}
  end

  defp reduce_league_result({{:ok, {:ok, event_ids}}, _league_id}, acc) do
    %{acc | event_ids: [acc.event_ids, event_ids]}
  end

  defp reduce_league_result({{:error, reason}, league_id}, acc) do
    # when the task has failed
    %{acc | failed_league_lookups: [{league_id, reason} | acc.failed_league_lookups]}
  end

  defp reduce_league_result({{:ok, {:error, reason}}, league_id}, acc) do
    # when task succeeded but request returned an error
    %{acc | failed_league_lookups: [{league_id, reason} | acc.failed_league_lookups]}
  end
end
