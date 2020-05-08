defmodule DiffEngine.Change.Market.MarketOrderChanged do
  defstruct [
    :event_id,
    :market_id,
    :order
  ]
end
