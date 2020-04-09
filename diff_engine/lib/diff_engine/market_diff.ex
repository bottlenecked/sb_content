defmodule DiffEngine.MarketDiff do
  alias DiffEngine.Result.Market.{MarketRemoved, MarketCreated}

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

    (removed_markets_results ++ created_markets_results)
    |> Enum.map(fn result -> %{result | event_id: ev_id} end)
  end

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
