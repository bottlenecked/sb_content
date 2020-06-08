defmodule Geneity.Parser.HierarchyParserTest do
  use ExUnit.Case, async: true

  test "can parse hierarchy" do
    result =
      "hierarchy_foot"
      |> Helpers.load_xml_file()
      |> Geneity.Parser.HierarchyParser.get_league_ids!()

    assert ["182758" | _] = result
    assert length(result) == 41
  end
end
