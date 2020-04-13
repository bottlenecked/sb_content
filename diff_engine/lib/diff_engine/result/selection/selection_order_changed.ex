defmodule DiffEngine.Result.Selection.SelectionOrderChanged do
  defstruct [
    :event_id,
    :market_id,
    :selection_id,
    :order
  ]
end
