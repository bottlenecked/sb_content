defmodule DiffEngine.Change.EventRemoved do
  # This change is special in that it is not produced by the diff_engine but from
  # the State.EventWorker polling the api- so look for it there
  defstruct [
    :event_id
  ]
end
