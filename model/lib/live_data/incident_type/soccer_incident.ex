defmodule Model.LiveData.IncidentType.SoccerIncident do
  @types [
    :goal,
    :cancel_goal,
    :corner,
    :cancel_corner,
    :red_card,
    :cancel_red_card,
    :yellow_card,
    :cancel_yellow_card,
    :free_kick,
    :goal_kick,
    :throw_in
  ]

  for type <- @types do
    def unquote(type)(), do: unquote(type)
  end
end
