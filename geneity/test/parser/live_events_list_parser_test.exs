defmodule Geneity.Parser.LiveEventsListParserTest do
  use ExUnit.Case, async: true

  test "can parse live events" do
    result =
      "live_events"
      |> Helpers.load_xml_file()
      |> Geneity.Parser.LeagueParser.get_event_ids!()

    assert [5_322_917 | _] = result
    assert length(result) == 31
  end
end
