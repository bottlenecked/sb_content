defmodule DiffEngine.MarketDiffTest do
  use ExUnit.Case, async: true

  alias Model.{Event, Market}
  alias DiffEngine.MarketDiff

  alias DiffEngine.Result.Market.{
    MarketRemoved,
    MarketCreated,
    MarketOrderChanged,
    MarketStatusChanged,
    MarketVisibilityChanged
  }

  test "markets tracked correctly when added or removed" do
    prev_markets =
      [1, 2, 3, 4, 5]
      |> Enum.map(fn i -> %Market{id: i} end)

    next_markets =
      [3, 4, 5, 6, 7]
      |> Enum.map(fn i -> %Market{id: i} end)

    ev_id = 1

    diffs =
      MarketDiff.diff(%Event{id: ev_id, markets: prev_markets}, %Event{
        id: ev_id,
        markets: next_markets
      })

    assert [
             %MarketRemoved{event_id: ev_id, market_id: 1},
             %MarketRemoved{event_id: ev_id, market_id: 2},
             %MarketCreated{event_id: ev_id, market: %Market{id: 6}},
             %MarketCreated{event_id: ev_id, market: %Market{id: 7}}
           ] = diffs
  end

  test "market order changed test" do
    prev_markets =
      [
        {1, 1},
        {2, 2},
        {3, 3}
      ]
      |> Enum.map(fn {id, order} -> %Market{id: id, order: order} end)

    next_markets =
      [
        # swap first and third markets
        {1, 3},
        {2, 2},
        {3, 1}
      ]
      |> Enum.map(fn {id, order} -> %Market{id: id, order: order} end)

    ev_id = 1

    diffs =
      MarketDiff.diff(%Event{id: ev_id, markets: prev_markets}, %Event{
        id: ev_id,
        markets: next_markets
      })

    assert [
             %MarketOrderChanged{event_id: ev_id, market_id: 1, order: 3},
             %MarketOrderChanged{event_id: ev_id, market_id: 3, order: 1}
           ] = diffs
  end

  test "market status changed test" do
    prev_markets =
      [
        {1, true},
        {2, false}
      ]
      |> Enum.map(fn {id, value} -> %Market{id: id, active?: value} end)

    next_markets =
      [
        # make 2nd market active
        {1, true},
        {2, true}
      ]
      |> Enum.map(fn {id, value} -> %Market{id: id, active?: value} end)

    ev_id = 1

    diffs =
      MarketDiff.diff(%Event{id: ev_id, markets: prev_markets}, %Event{
        id: ev_id,
        markets: next_markets
      })

    assert [
             %MarketStatusChanged{event_id: ev_id, market_id: 2, active?: true}
           ] = diffs
  end

  test "market visibility changed test" do
    prev_markets =
      [
        {1, true},
        {2, false}
      ]
      |> Enum.map(fn {id, value} -> %Market{id: id, displayed?: value} end)

    next_markets =
      [
        # make 2nd market displayed
        {1, true},
        {2, true}
      ]
      |> Enum.map(fn {id, value} -> %Market{id: id, displayed?: value} end)

    ev_id = 1

    diffs =
      MarketDiff.diff(%Event{id: ev_id, markets: prev_markets}, %Event{
        id: ev_id,
        markets: next_markets
      })

    assert [
             %MarketVisibilityChanged{event_id: ev_id, market_id: 2, displayed?: true}
           ] = diffs
  end
end
