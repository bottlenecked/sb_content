defmodule Geneity.Parser.SportListParserTest do
  use ExUnit.Case, async: true

  test "can parse sports" do
    result =
      "sports"
      |> Helpers.load_xml_file()
      |> Geneity.Parser.SportListParser.get_sport_ids!()

    assert ["FOOT" | _] = result
    assert length(result) == 52
  end
end
