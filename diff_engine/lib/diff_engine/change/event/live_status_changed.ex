defmodule DiffEngine.Change.Event.LiveStatusChanged do
  defstruct [
    :event_id,
    :live?
  ]
end
