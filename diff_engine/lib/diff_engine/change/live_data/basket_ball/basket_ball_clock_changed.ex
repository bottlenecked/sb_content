defmodule DiffEngine.Change.LiveData.BasketBall.BasketBallClockChanged do
  defstruct [
    :event_id,
    :current_period,
    :total_ellapsed_seconds,
    :correct_at,
    :time_ticking?
  ]
end
