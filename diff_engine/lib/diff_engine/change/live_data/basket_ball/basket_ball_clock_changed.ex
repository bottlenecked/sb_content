defmodule DiffEngine.Change.LiveData.BasketBall.BasketBallClockChanged do
  defstruct [
    :event_id,
    :current_period,
    :remaining_seconds_in_period,
    :correct_at,
    :time_ticking?
  ]
end
