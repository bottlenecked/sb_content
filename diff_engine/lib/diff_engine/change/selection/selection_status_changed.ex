defmodule DiffEngine.Change.Selection.SelectionStatusChanged do
  defstruct [
    :event_id,
    :market_id,
    :selection_id,
    :active?
  ]
end
