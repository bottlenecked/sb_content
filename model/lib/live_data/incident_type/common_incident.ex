defmodule Model.LiveData.IncidentType.CommonIncident do
  @moduledoc """
  Defines common incidents found across all events
  """
  @types [
    :event_start,
    :event_end,
    :period_start,
    :period_end,
    :comment
  ]

  for type <- @types do
    def unquote(type)(), do: unquote(type)
  end
end
