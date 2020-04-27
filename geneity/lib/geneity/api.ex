defmodule Geneity.Api do
  alias Geneity.Api.Operators

  @spec get_event_data(pos_integer(), String.t(), String.t()) ::
          {:ok, Event.t()} | {:error, any()}
  def get_event_data(event_id, operator_id \\ Operators.stoiximan_gr(), language \\ "en") do
    path =
      "/content_api?key=get_inplay_event_detail&lang=#{language}&ev_id=#{event_id}&pocasite=#{
        operator_id
      }"

    headers = [
      {"Connection", "Keep-Alive"},
      {"X-Geneity-Site", operator_id}
    ]

    Freshness.get(:geneity, path, headers)
    |> Geneity.Api.EventResponseProcessor.process()
  end

  @spec get_sport_ids(String.t()) ::
          {:ok, list(String.t())} | {:error, any()}
  def get_sport_ids(operator_id \\ Operators.stoiximan_gr()) do
    path = "/content_api?key=get_sports&lang=en&pocasite=#{operator_id}"

    headers = [
      {"Connection", "Keep-Alive"},
      {"X-Geneity-Site", operator_id}
    ]

    Freshness.get(:geneity, path, headers)
    |> Geneity.Api.ListProcessor.process(&Geneity.Parser.SportListParser.get_sport_ids/1)
  end

  @spec get_league_ids_for_sport(String.t(), String.t()) ::
          {:ok, list(String.t())} | {:error, any()}
  def get_league_ids_for_sport(sport_id, operator_id \\ Operators.stoiximan_gr()) do
    path = "/content_api?key=get_hierarchy&sport_code=#{sport_id}&pocasite=#{operator_id}"

    headers = [
      {"Connection", "Keep-Alive"},
      {"X-Geneity-Site", operator_id}
    ]

    Freshness.get(:geneity, path, headers)
    |> Geneity.Api.ListProcessor.process(&Geneity.Parser.HierarchyParser.get_league_ids/1)
  end

  def get_event_ids_for_league(league_id, operator_id \\ Operators.stoiximan_gr()) do
    path =
      "/content_api?key=get_events_for_type&sb_type_id=#{league_id}&upcoming_period=1000000000&pocasite=#{
        operator_id
      }"

    headers = [
      {"Connection", "Keep-Alive"},
      {"X-Geneity-Site", operator_id}
    ]

    Freshness.get(:geneity, path, headers)
    |> Geneity.Api.ListProcessor.process(&Geneity.Parser.LeagueParser.get_event_ids/1)
  end

  def get_live_event_ids(operator_id \\ Operators.stoiximan_gr()) do
    path = "/content_api?key=get_inplay_schedule&upcoming_period=1&&pocasite=#{operator_id}"

    headers = [
      {"Connection", "Keep-Alive"},
      {"X-Geneity-Site", operator_id}
    ]

    Freshness.get(:geneity, path, headers)
    |> Geneity.Api.ListProcessor.process(&Geneity.Parser.LeagueParser.get_event_ids/1)
  end
end
