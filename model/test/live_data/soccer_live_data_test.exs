defmodule Model.LiveData.SoccerLiveDataTest do
  use ExUnit.Case, async: true

  alias Model.LiveData.{SoccerLiveData, Incident}
  alias Model.LiveData.IncidentType.{CommonIncident, SoccerIncident}

  test "adding and subtracting goals" do
    home_team_id = 1
    away_team_id = 2

    incidents =
      [
        {home_team_id, SoccerIncident.goal()},
        {away_team_id, SoccerIncident.goal()},
        {home_team_id, SoccerIncident.goal()},
        {home_team_id, SoccerIncident.goal()},
        {home_team_id, SoccerIncident.cancel_goal()},
        {away_team_id, SoccerIncident.cancel_goal()},
        {away_team_id, SoccerIncident.goal()}
      ]
      |> Enum.with_index()
      |> Enum.map(fn {{team_id, type}, idx} ->
        %Incident{id: idx, type: type, team_id: team_id}
      end)

    data = SoccerLiveData.update_live_data(%SoccerLiveData{}, incidents, home_team_id)

    assert data.score.home == 2
    assert data.score.away == 1
  end

  test "adding and subtracting corners" do
    home_team_id = 1
    away_team_id = 2

    incidents =
      [
        {home_team_id, SoccerIncident.corner()},
        {away_team_id, SoccerIncident.corner()},
        {home_team_id, SoccerIncident.corner()},
        {home_team_id, SoccerIncident.corner()},
        {home_team_id, SoccerIncident.cancel_corner()},
        {away_team_id, SoccerIncident.cancel_corner()},
        {away_team_id, SoccerIncident.corner()}
      ]
      |> Enum.with_index()
      |> Enum.map(fn {{team_id, type}, idx} ->
        %Incident{id: idx, type: type, team_id: team_id}
      end)

    data = SoccerLiveData.update_live_data(%SoccerLiveData{}, incidents, home_team_id)

    assert data.corners.home == 2
    assert data.corners.away == 1
  end

  test "adding and subtracting red_cards" do
    home_team_id = 1
    away_team_id = 2

    incidents =
      [
        {home_team_id, SoccerIncident.red_card()},
        {away_team_id, SoccerIncident.red_card()},
        {home_team_id, SoccerIncident.red_card()},
        {home_team_id, SoccerIncident.red_card()},
        {home_team_id, SoccerIncident.cancel_red_card()},
        {away_team_id, SoccerIncident.cancel_red_card()},
        {away_team_id, SoccerIncident.red_card()}
      ]
      |> Enum.with_index()
      |> Enum.map(fn {{team_id, type}, idx} ->
        %Incident{id: idx, type: type, team_id: team_id}
      end)

    data = SoccerLiveData.update_live_data(%SoccerLiveData{}, incidents, home_team_id)

    assert data.red_cards.home == 2
    assert data.red_cards.away == 1
  end

  test "adding and subtracting yellow_cards" do
    home_team_id = 1
    away_team_id = 2

    incidents =
      [
        {home_team_id, SoccerIncident.yellow_card()},
        {away_team_id, SoccerIncident.yellow_card()},
        {home_team_id, SoccerIncident.yellow_card()},
        {home_team_id, SoccerIncident.yellow_card()},
        {home_team_id, SoccerIncident.cancel_yellow_card()},
        {away_team_id, SoccerIncident.cancel_yellow_card()},
        {away_team_id, SoccerIncident.yellow_card()}
      ]
      |> Enum.with_index()
      |> Enum.map(fn {{team_id, type}, idx} ->
        %Incident{id: idx, type: type, team_id: team_id}
      end)

    data = SoccerLiveData.update_live_data(%SoccerLiveData{}, incidents, home_team_id)

    assert data.yellow_cards.home == 2
    assert data.yellow_cards.away == 1
  end

  test "period counting" do
    incidents =
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

    data = SoccerLiveData.update_live_data(%SoccerLiveData{}, incidents, :none)

    assert data.current_period == 3
  end
end
