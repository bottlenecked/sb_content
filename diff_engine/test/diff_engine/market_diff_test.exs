defmodule DiffEngine.MarketDiffTest do
  use ExUnit.Case, async: true

  alias Model.{Event, Market}
  alias DiffEngine.MarketDiff
  alias DiffEngine.Result.Market.{MarketRemoved, MarketCreated}

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
end
