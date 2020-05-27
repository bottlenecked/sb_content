defmodule Geneity.BasketBallParserTest do
  use ExUnit.Case, async: true
  doctest Geneity.Parser

  alias Model.Event
  alias Model.LiveData.{BasketBallLiveData, HomeAwayStat}

  test "parse basketball live data" do
    result =
      "events/bask_event"
      |> Helpers.load_xml_file()
      |> Geneity.Parser.parse_event_xml!()

    assert %Event{
             live_data: %BasketBallLiveData{} = live_data
           } = result

    assert %{
             current_period: 2,
             regular_periods_count: 4,
             max_extra_periods_count: 5,
             total_ellapsed_seconds: 1196,
             correct_at: ~U[2020-03-30 11:59:40Z],
             regular_period_length: 600,
             extra_period_length: 300,
             time_ticking?: true,
             score: %HomeAwayStat{home: 35, away: 51},
             period_scores: [
               %{home: 18, away: 30},
               %{home: 17, away: 21}
             ]
           } = live_data
  end
end
