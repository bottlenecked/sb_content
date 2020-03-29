defmodule Geneity.Parser.Test do
  use ExUnit.Case
  doctest Geneity.Parser

  alias Model.{Event, Market, Selection}

  test "Parse football event" do
    result =
      "foot_event"
      |> Helpers.load_xml_file()
      |> Geneity.Parser.parse_event_xml()

    assert %Event{
             id: 5_113_307,
             sport_id: "FOOT",
             zone_id: 11395,
             league_id: 17221,
             start_time: ~U[2020-03-29 15:00:00Z],
             active: true,
             displayed: true,
             live: true,
             display_order: -1200,
             markets: markets
           } = result

    assert [
             %Market{
               id: 200_196_701,
               type_id: "MRES",
               active: true,
               displayed: true,
               selections: selections
             }
             | _
           ] = markets

    assert Enum.count(markets) == 174

    assert [
             %Selection{
               id: 848_691_656,
               type_id: "H",
               active: true,
               price_decimal: 2.85
             }
             | _
           ] = selections

    assert Enum.count(selections) == 3
  end
end
