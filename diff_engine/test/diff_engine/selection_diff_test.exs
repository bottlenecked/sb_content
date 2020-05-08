defmodule DiffEngine.MarketSelectionTest do
  use ExUnit.Case, async: true

  alias Model.{Market, Selection}
  alias DiffEngine.SelectionDiff

  alias DiffEngine.Change.Selection.{
    SelectionRemoved,
    SelectionCreated,
    SelectionOrderChanged,
    SelectionStatusChanged,
    SelectionVisibilityChanged,
    SelectionPriceChanged
  }

  test "selections tracked correctly when added or removed" do
    prev_selections =
      [1, 2, 3, 4, 5]
      |> Enum.map(fn i -> %Selection{id: i} end)

    next_selections =
      [3, 4, 5, 6, 7]
      |> Enum.map(fn i -> %Selection{id: i} end)

    mkt_id = 1

    diffs =
      SelectionDiff.diff(%Market{id: mkt_id, selections: prev_selections}, %Market{
        id: mkt_id,
        selections: next_selections
      })

    assert [
             %SelectionRemoved{market_id: mkt_id, selection_id: 1},
             %SelectionRemoved{market_id: mkt_id, selection_id: 2},
             %SelectionCreated{market_id: mkt_id, selection: %Selection{id: 6}},
             %SelectionCreated{market_id: mkt_id, selection: %Selection{id: 7}}
           ] = diffs
  end

  test "selection order changed test" do
    prev_selections =
      [
        {1, 1},
        {2, 2},
        {3, 3}
      ]
      |> Enum.map(fn {id, order} -> %Selection{id: id, order: order} end)

    next_selections =
      [
        # swap first and third selections
        {1, 3},
        {2, 2},
        {3, 1}
      ]
      |> Enum.map(fn {id, order} -> %Selection{id: id, order: order} end)

    mkt_id = 1

    diffs =
      SelectionDiff.diff(%Market{id: mkt_id, selections: prev_selections}, %Market{
        id: mkt_id,
        selections: next_selections
      })

    assert [
             %SelectionOrderChanged{market_id: mkt_id, selection_id: 1, order: 3},
             %SelectionOrderChanged{market_id: mkt_id, selection_id: 3, order: 1}
           ] = diffs
  end

  test "selection status changed test" do
    prev_selections =
      [
        {1, true},
        {2, false}
      ]
      |> Enum.map(fn {id, value} -> %Selection{id: id, active?: value} end)

    next_selections =
      [
        # make 2nd selection active
        {1, true},
        {2, true}
      ]
      |> Enum.map(fn {id, value} -> %Selection{id: id, active?: value} end)

    mkt_id = 1

    diffs =
      SelectionDiff.diff(%Market{id: mkt_id, selections: prev_selections}, %Market{
        id: mkt_id,
        selections: next_selections
      })

    assert [
             %SelectionStatusChanged{market_id: mkt_id, selection_id: 2, active?: true}
           ] = diffs
  end

  test "selection visibility changed test" do
    prev_selections =
      [
        {1, true},
        {2, false}
      ]
      |> Enum.map(fn {id, value} -> %Selection{id: id, displayed?: value} end)

    next_selections =
      [
        # make 2nd selection displayed
        {1, true},
        {2, true}
      ]
      |> Enum.map(fn {id, value} -> %Selection{id: id, displayed?: value} end)

    mkt_id = 1

    diffs =
      SelectionDiff.diff(%Market{id: mkt_id, selections: prev_selections}, %Market{
        id: mkt_id,
        selections: next_selections
      })

    assert [
             %SelectionVisibilityChanged{market_id: mkt_id, selection_id: 2, displayed?: true}
           ] = diffs
  end

  test "selection price changed test" do
    prev_selections =
      [
        {1, 1.10},
        {2, 2.20}
      ]
      |> Enum.map(fn {id, value} -> %Selection{id: id, price_decimal: value} end)

    next_selections =
      [
        # increase price of 2nd selection
        {1, 1.10},
        {2, 2.30}
      ]
      |> Enum.map(fn {id, value} -> %Selection{id: id, price_decimal: value} end)

    mkt_id = 1

    diffs =
      SelectionDiff.diff(%Market{id: mkt_id, selections: prev_selections}, %Market{
        id: mkt_id,
        selections: next_selections
      })

    assert [
             %SelectionPriceChanged{market_id: mkt_id, selection_id: 2, price_decimal: 2.30}
           ] = diffs
  end
end
