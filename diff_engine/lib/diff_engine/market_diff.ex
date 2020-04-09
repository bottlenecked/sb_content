defmodule DiffEngine.MarketDiff do
  alias Model.Market
  alias DiffEngine.Result.NoDiff
  alias DiffEngine.Result.Market.{MarketRemoved, MarketCreated, MarketOrderChanged}

  def diff(%{markets: prev_markets}, %{id: ev_id, markets: next_markets}) do
    next_markets_map = markets_to_map(next_markets)
    prev_markets_map = markets_to_map(prev_markets)

    removed_markets_results =
      prev_markets
      |> detect_missing_markets(next_markets_map)
      |> Enum.map(fn mkt -> %MarketRemoved{market_id: mkt.id} end)

    created_markets_results =
      next_markets
      |> detect_missing_markets(prev_markets_map)
      |> Enum.map(fn mkt -> %MarketCreated{market: mkt} end)

    # lastly grab all markets present both before and afterwards
    # and run all checks on each one

    market_pairs_to_compare =
      prev_markets
      |> Enum.map(fn mkt -> {mkt, Map.get(next_markets_map, mkt.id)} end)
      |> Enum.filter(fn {_prev, next} -> next != nil end)

    diff_funs = [
      &diff_order/2
    ]

    comparison_results =
      for {prev_market, next_market} <- market_pairs_to_compare, diff_fun <- diff_funs do
        diff_fun.(prev_market, next_market)
      end
      |> Enum.filter(fn res -> res != NoDiff.value() end)

    (removed_markets_results ++ created_markets_results ++ comparison_results)
    |> Enum.map(fn result -> %{result | event_id: ev_id} end)
  end

  def diff_order(%Market{order: prev_value}, %Market{order: next_value})
      when prev_value == next_value,
      do: NoDiff.value()

  def diff_order(_prev, %Market{order: next_value, id: id}),
    do: %MarketOrderChanged{market_id: id, order: next_value}

  defp detect_missing_markets(base_line, target) do
    base_line
    |> Enum.filter(fn mkt -> !Map.has_key?(target, mkt.id) end)
  end

  defp markets_to_map(markets) do
    markets
    |> Enum.map(fn mkt -> {mkt.id, mkt} end)
    |> Map.new()
  end
end
