defmodule DiffEngine.Result.LiveData.Soccer.SoccerClockChanged do
  defstruct [
    :event_id,
    :current_period,
    :total_ellapsed_seconds,
    :correct_at,
    :time_ticking?
  ]
end
