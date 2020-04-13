defmodule DiffEngine.Result.Market.MarketStatusChanged do
  defstruct [
    :event_id,
    :market_id,
    :active?
  ]
end
