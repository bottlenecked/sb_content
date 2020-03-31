defmodule Model.LiveData.SoccerLiveDataTest do
  use ExUnit.Case, async: true

  alias Model.LiveData.{SoccerLiveData, Incident}
  alias Model.LiveData.SoccerLiveData.IncidentType, as: Type

  test "adding and subtracting goals" do
    home_team_id = 1
    away_team_id = 2

    data =
      [
        {home_team_id, Type.goal()},
        {away_team_id, Type.goal()},
        {home_team_id, Type.goal()},
        {home_team_id, Type.goal()},
        {home_team_id, Type.cancel_goal()},
        {away_team_id, Type.cancel_goal()},
        {away_team_id, Type.goal()}
      ]
      |> Enum.with_index()
      |> Enum.map(fn {{team_id, type}, idx} ->
        %Incident{id: idx, type: type, team_id: team_id}
      end)
      |> SoccerLiveData.update_live_data(%SoccerLiveData{}, home_team_id)

    assert data.score.home == 2
    assert data.score.away == 1
  end
end
