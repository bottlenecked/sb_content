defmodule Model.LiveData.SoccerLiveData do
  alias Model.LiveData.{HomeAwayStat, Incident}
  alias Model.LiveData.IncidentType.{CommonIncident, SoccerIncident}

  @zero_stat %HomeAwayStat{}

  @type t() :: %__MODULE__{}

  defstruct [
    :current_period,
    :total_ellapsed_seconds,
    :correct_at,
    :regular_periods_count,
    :max_extra_periods_count,
    :regular_period_length,
    :extra_period_length,
    :time_ticking?,
    score: @zero_stat,
    red_cards: @zero_stat,
    yellow_cards: @zero_stat,
    corners: @zero_stat,
    incidents: []
  ]

  @spec update_live_data(t(), list(Incident.t()), integer()) :: t()
  def update_live_data(
        %__MODULE__{} = data,
        incidents_asc,
        home_team_id
      ) do
    incidents_asc
    |> Enum.reduce(data, fn inc, acc -> handle_incident(inc, acc, home_team_id) end)
  end

  ## INCIDENT HANDLING

  @event_start CommonIncident.event_start()
  defp handle_incident(%{type: @event_start}, data, _home_team_id) do
    put_in(data.current_period, 0)
  end

  @period_start CommonIncident.period_start()

  defp handle_incident(%{type: @period_start}, data, _home_team_id) do
    put_in(data.current_period, data.current_period + 1)
  end

  # goals

  @goal SoccerIncident.goal()
  @cancel_goal SoccerIncident.cancel_goal()

  defp handle_incident(%{type: @goal, team_id: team_id}, data, home_team_id)
       when team_id == home_team_id do
    put_in(data.score.home, data.score.home + 1)
  end

  defp handle_incident(%{type: @goal}, data, _home_team_id) do
    put_in(data.score.away, data.score.away + 1)
  end

  defp handle_incident(%{type: @cancel_goal, team_id: team_id}, data, home_team_id)
       when team_id == home_team_id do
    put_in(data.score.home, data.score.home - 1)
  end

  defp handle_incident(%{type: @cancel_goal}, data, _home_team_id) do
    put_in(data.score.away, data.score.away - 1)
  end

  # corners

  @corner SoccerIncident.corner()
  @cancel_corner SoccerIncident.cancel_corner()

  defp handle_incident(%{type: @corner, team_id: team_id}, data, home_team_id)
       when team_id == home_team_id do
    put_in(data.corners.home, data.corners.home + 1)
  end

  defp handle_incident(%{type: @corner}, data, _home_team_id) do
    put_in(data.corners.away, data.corners.away + 1)
  end

  defp handle_incident(%{type: @cancel_corner, team_id: team_id}, data, home_team_id)
       when team_id == home_team_id do
    put_in(data.corners.home, data.corners.home - 1)
  end

  defp handle_incident(%{type: @cancel_corner}, data, _home_team_id) do
    put_in(data.corners.away, data.corners.away - 1)
  end

  # red cards

  @red_card SoccerIncident.red_card()
  @cancel_red_card SoccerIncident.cancel_red_card()

  defp handle_incident(%{type: @red_card, team_id: team_id}, data, home_team_id)
       when team_id == home_team_id do
    put_in(data.red_cards.home, data.red_cards.home + 1)
  end

  defp handle_incident(%{type: @red_card}, data, _home_team_id) do
    put_in(data.red_cards.away, data.red_cards.away + 1)
  end

  defp handle_incident(%{type: @cancel_red_card, team_id: team_id}, data, home_team_id)
       when team_id == home_team_id do
    put_in(data.red_cards.home, data.red_cards.home - 1)
  end

  defp handle_incident(%{type: @cancel_red_card}, data, _home_team_id) do
    put_in(data.red_cards.away, data.red_cards.away - 1)
  end

  # yellow cards

  @yellow_card SoccerIncident.yellow_card()
  @cancel_yellow_card SoccerIncident.cancel_yellow_card()

  defp handle_incident(%{type: @yellow_card, team_id: team_id}, data, home_team_id)
       when team_id == home_team_id do
    put_in(data.yellow_cards.home, data.yellow_cards.home + 1)
  end

  defp handle_incident(%{type: @yellow_card}, data, _home_team_id) do
    put_in(data.yellow_cards.away, data.yellow_cards.away + 1)
  end

  defp handle_incident(%{type: @cancel_yellow_card, team_id: team_id}, data, home_team_id)
       when team_id == home_team_id do
    put_in(data.yellow_cards.home, data.yellow_cards.home - 1)
  end

  defp handle_incident(%{type: @cancel_yellow_card}, data, _home_team_id) do
    put_in(data.yellow_cards.away, data.yellow_cards.away - 1)
  end

  defp handle_incident(_incident, data, _home_team_id), do: data
end
