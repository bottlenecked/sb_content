defmodule Geneity.Parser.LeagueParserTest do
  use ExUnit.Case, async: true

  test "can parse event ids" do
    result =
      "events_in_league"
      |> Helpers.load_xml_file()
      |> Geneity.Parser.LeagueParser.get_event_ids!()

    assert [5_324_043 | _] = result
    assert length(result) == 20
  end
end
