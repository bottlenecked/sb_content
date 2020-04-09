defmodule DiffEngine.Result.Market.MarketOrderChanged do
  defstruct [
    :event_id,
    :market_id,
    :order
  ]
end
