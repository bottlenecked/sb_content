defmodule Geneity.ParserTest do
  use ExUnit.Case, async: true
  doctest Geneity.Parser

  alias Model.{Event, Market, Selection, Team}
  alias Model.LiveData.{SoccerLiveData, Incident}
  alias Model.LiveData.IncidentType.{CommonIncident, SoccerIncident}

  test "Parse football event" do
    result =
      "events/foot_event"
      |> Helpers.load_xml_file()
      |> Geneity.Parser.parse_event_xml!()

    assert %Event{
             id: "5113307",
             sport_id: "FOOT",
             zone_id: "11395",
             league_id: "17221",
             br_match_id: "21752575",
             start_time: ~U[2020-03-29 15:00:00Z],
             active?: true,
             displayed?: true,
             live?: true,
             display_order: -33_749_001_200,
             markets: markets,
             teams: teams,
             live_data: live_data
           } = result

    assert [
             %Market{
               id: "200196701",
               type_id: "MRES",
               active?: true,
               displayed?: false,
               selections: selections
             }
             | _
           ] = markets

    assert Enum.count(markets) == 174

    assert [
             %Selection{
               id: "848691656",
               type_id: "H",
               active?: true,
               price_decimal: 2.85,
               order: 0
             }
             | _
           ] = selections

    assert Enum.count(selections) == 3

    assert [%Team{id: "107953"}, %Team{}] = teams

    assert %SoccerLiveData{
             current_period: 1,
             regular_periods_count: 2,
             max_extra_periods_count: 2,
             total_ellapsed_seconds: 1026,
             correct_at: ~U[2020-03-29 15:18:54Z],
             regular_period_length: 2700,
             extra_period_length: 900,
             time_ticking?: true
           } = live_data

    %{incidents: incidents} = live_data

    # incidents are stored from last to first, lets reverse here
    # because it helps with some aspects in testing
    incidents = Enum.reverse(incidents)

    assert [
             %Incident{
               id: "189417919",
               type: event_start_type,
               game_time: 1,
               timestamp: ~U[2020-03-29 15:01:48Z]
             },
             _,
             %Incident{
               team_id: "107953",
               type: free_kick_type
             },
             _,
             %Incident{
               type: comment_type,
               extra: "First to happen:Free Kick"
             }
             | _
           ] = incidents

    assert event_start_type == CommonIncident.event_start()
    assert free_kick_type == SoccerIncident.free_kick()
    assert comment_type = CommonIncident.comment()
    assert Enum.count(incidents) == 32
  end

  test "Parse event with goals" do
    result =
      "events/foot_goals"
      |> Helpers.load_xml_file()
      |> Geneity.Parser.parse_event_xml!()

    assert %{live_data: %SoccerLiveData{} = live_data} = result
    assert %{score: %{home: 1, away: 2}} = live_data
  end

  test "parse market closing time" do
    result =
      "events/foot_outright_event"
      |> Helpers.load_xml_file()
      |> Geneity.Parser.parse_event_xml!()

    assert %{
             markets: [
               %{close_time: ~U"2021-06-11 12:00:00Z"}
               | _rest
             ]
           } = result
  end
end
