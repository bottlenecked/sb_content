defmodule Model.LiveData.Incident do
  defstruct [
    :id,
    :type,
    :team_id,
    :game_time,
    :timestamp,
    :extra
  ]
end
