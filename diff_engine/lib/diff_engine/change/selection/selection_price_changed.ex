defmodule DiffEngine.Change.Selection.SelectionPriceChanged do
  defstruct [
    :event_id,
    :market_id,
    :selection_id,
    :price_decimal
  ]
end
