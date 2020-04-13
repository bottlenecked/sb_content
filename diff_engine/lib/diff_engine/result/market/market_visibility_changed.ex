defmodule DiffEngine.Result.Market.MarketVisibilityChanged do
  defstruct [
    :event_id,
    :market_id,
    :displayed?
  ]
end
