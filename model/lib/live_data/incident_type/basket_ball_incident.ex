defmodule Model.LiveData.IncidentType.BasketBallIncident do
  @types [
    :one_point,
    :cancel_one_point,
    :two_point,
    :cancel_two_point,
    :three_point,
    :cancel_three_point,
    :foul,
    :cancel_foul
  ]

  for type <- @types do
    def unquote(type)(), do: unquote(type)
  end
end
