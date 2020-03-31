defmodule Model.LiveData.Incident do
  @type p :: %__MODULE__{}
  defstruct [
    :id,
    :type,
    :team_id,
    :game_time,
    :timestamp,
    :extra
  ]
end
