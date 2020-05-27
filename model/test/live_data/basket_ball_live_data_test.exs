defmodule Model.LiveData.BasketBallLiveDataTest do
  use ExUnit.Case, async: true

  alias Model.LiveData.{BasketBallLiveData, Incident}
  alias Model.LiveData.IncidentType.{CommonIncident, BasketBallIncident}

  test "adding and subtracting points" do
    home_team_id = 1
    away_team_id = 2

    data =
      [
        {0, CommonIncident.event_start()},
        {0, CommonIncident.period_start()},
        {home_team_id, BasketBallIncident.two_point()},
        {away_team_id, BasketBallIncident.two_point()},
        {away_team_id, BasketBallIncident.cancel_two_point()},
        {home_team_id, BasketBallIncident.one_point()},
        {home_team_id, BasketBallIncident.one_point()},
        {home_team_id, BasketBallIncident.cancel_one_point()},
        {away_team_id, BasketBallIncident.three_point()},
        {0, CommonIncident.period_end()},
        {0, CommonIncident.period_start()},
        {home_team_id, BasketBallIncident.two_point()},
        {away_team_id, BasketBallIncident.two_point()}
      ]
      |> Enum.with_index()
      |> Enum.map(fn {{team_id, type}, idx} ->
        %Incident{id: idx, type: type, team_id: team_id}
      end)
      |> BasketBallLiveData.update_live_data(%BasketBallLiveData{}, home_team_id)

    assert data.score.home == 5
    assert data.score.away == 5

    assert data.current_period == 2

    assert [
             %{home: 3, away: 3},
             %{home: 2, away: 2}
           ] = data.period_scores
  end

  test "period counting" do
    data =
      [
        CommonIncident.event_start(),
        CommonIncident.period_start(),
        CommonIncident.period_end(),
        CommonIncident.period_start(),
        CommonIncident.period_end(),
        CommonIncident.period_start(),
        CommonIncident.period_end()
      ]
      |> Enum.with_index()
      |> Enum.map(fn {type, idx} ->
        %Incident{id: idx, type: type}
      end)
      |> BasketBallLiveData.update_live_data(%BasketBallLiveData{}, :none)

    assert data.current_period == 3
  end
end
