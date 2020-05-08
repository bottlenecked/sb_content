defmodule Geneity.Api do
  alias Geneity.Api.Operator
  alias Model.Event
  alias Freshness.Response

  @spec get_event_data(pos_integer(), Operator.t(), String.t()) ::
          {:ok, Event.t()} | {:error, any()}
  def get_event_data(event_id, operator_id \\ Operator.stoiximan_gr(), language \\ "en") do
    path =
      "/content_api?key=get_inplay_event_detail&lang=#{language}&ev_id=#{event_id}&pocasite=#{
        operator_id
      }"

    headers = [
      {"Connection", "Keep-Alive"},
      {"X-Geneity-Site", operator_id}
    ]

    path
    |> do_request(headers)
    |> process_result(&Geneity.Parser.parse_event_xml/1)
    |> case do
      {:ok, %Event{id: nil}} -> {:error, :event_not_found}
      other -> other
    end
  end

  @spec get_sport_ids(Operator.t()) ::
          {:ok, list(String.t())} | {:error, any()}
  def get_sport_ids(operator_id \\ Operator.stoiximan_gr()) do
    path = "/content_api?key=get_sports&lang=en&pocasite=#{operator_id}"

    headers = [
      {"Connection", "Keep-Alive"},
      {"X-Geneity-Site", operator_id}
    ]

    path
    |> do_request(headers)
    |> process_result(&Geneity.Parser.SportListParser.get_sport_ids/1)
  end

  @spec get_league_ids_for_sport(String.t(), Operator.t()) ::
          {:ok, list(non_neg_integer())} | {:error, any()}
  def get_league_ids_for_sport(sport_id, operator_id \\ Operator.stoiximan_gr()) do
    path = "/content_api?key=get_hierarchy&sport_code=#{sport_id}&pocasite=#{operator_id}"

    headers = [
      {"Connection", "Keep-Alive"},
      {"X-Geneity-Site", operator_id}
    ]

    path
    |> do_request(headers)
    |> process_result(&Geneity.Parser.HierarchyParser.get_league_ids/1)
  end

  @spec get_event_ids_for_league(non_neg_integer(), Operator.t()) ::
          {:ok, list(non_neg_integer())} | {:error, any()}
  def get_event_ids_for_league(league_id, operator_id \\ Operator.stoiximan_gr()) do
    path =
      "/content_api?key=get_events_for_type&sb_type_id=#{league_id}&upcoming_period=1000000000&pocasite=#{
        operator_id
      }"

    headers = [
      {"Connection", "Keep-Alive"},
      {"X-Geneity-Site", operator_id}
    ]

    path
    |> do_request(headers)
    |> process_result(&Geneity.Parser.LeagueParser.get_event_ids/1)
  end

  @spec get_live_event_ids(Operator.t()) ::
          {:ok, list(non_neg_integer())} | {:error, any()}
  def get_live_event_ids(operator_id \\ Operator.stoiximan_gr()) do
    path = "/content_api?key=get_inplay_schedule&upcoming_period=1&&pocasite=#{operator_id}"

    headers = [
      {"Connection", "Keep-Alive"},
      {"X-Geneity-Site", operator_id}
    ]

    path
    |> do_request(headers)
    |> process_result(&Geneity.Parser.LeagueParser.get_event_ids/1)
  end

  defp do_request(path, headers) do
    case Freshness.get(:geneity, path, headers) do
      {:error, %{reason: :closed}} -> do_request(path, headers)
      other -> other
    end
  end

  defp process_result(result, parse_fun) do
    with {:response, {:ok, response}} <- {:response, result},
         {:status, %Response{status: 200} = resp} <- {:status, response},
         {:parse, {:ok, response}} <- {:parse, parse_fun.(resp.data)} do
      {:ok, response}
    else
      {:response, {:error, _} = error} -> error
      {:status, %Response{status: status}} -> {:error, status}
      {:parse, {:error, _xml_error} = error} -> error
    end
  end
end
