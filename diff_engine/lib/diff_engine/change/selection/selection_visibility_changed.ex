defmodule DiffEngine.Change.Selection.SelectionVisibilityChanged do
  defstruct [
    :event_id,
    :market_id,
    :selection_id,
    :displayed?
  ]
end
