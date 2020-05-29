defmodule Model.LiveData.BasketBallLiveData do
  alias Model.LiveData.{HomeAwayStat, Incident}
  alias Model.LiveData.IncidentType.{CommonIncident, BasketBallIncident}

  @zero_stat %HomeAwayStat{}

  @type t() :: %__MODULE__{}

  defstruct [
    :current_period,
    :remaining_seconds_in_period,
    :correct_at,
    :regular_periods_count,
    :max_extra_periods_count,
    :regular_period_length,
    :extra_period_length,
    :time_ticking?,
    score: @zero_stat,
    period_scores: [],
    incidents: []
  ]

  def calculate_remaining_seconds_in_period(%__MODULE__{} = data, total_seconds_ellapsed) do
    data.regular_period_length * min(data.current_period, data.regular_periods_count) +
      data.extra_period_length * max(0, data.current_period - data.regular_periods_count) -
      total_seconds_ellapsed
  end

  @spec update_live_data(t(), list(Incident.t()), integer()) :: t()
  def update_live_data(
        %__MODULE__{} = data,
        incidents_asc,
        home_team_id
      ) do
    data =
      incidents_asc
      |> Enum.reduce(data, fn inc, acc -> handle_incident(inc, acc, home_team_id) end)

    %{data | period_scores: Enum.reverse(data.period_scores)}
  end

  ## INCIDENT HANDLING

  @event_start CommonIncident.event_start()
  defp handle_incident(%{type: @event_start}, data, _home_team_id) do
    put_in(data.current_period, 0)
  end

  @period_start CommonIncident.period_start()

  defp handle_incident(%{type: @period_start}, data, _home_team_id) do
    data = put_in(data.current_period, data.current_period + 1)
    put_in(data.period_scores, [@zero_stat | data.period_scores])
  end

  # points

  @one_point BasketBallIncident.one_point()
  @cancel_one_point BasketBallIncident.cancel_one_point()

  defp handle_incident(%{type: @one_point, team_id: team_id}, data, home_team_id)
       when team_id == home_team_id,
       do: update_score_data_by(data, :home, +1)

  defp handle_incident(%{type: @one_point}, data, _home_team_id),
    do: update_score_data_by(data, :away, +1)

  defp handle_incident(%{type: @cancel_one_point, team_id: team_id}, data, home_team_id)
       when team_id == home_team_id,
       do: update_score_data_by(data, :home, -1)

  defp handle_incident(%{type: @cancel_one_point}, data, _home_team_id),
    do: update_score_data_by(data, :away, -1)

  @two_point BasketBallIncident.two_point()
  @cancel_two_point BasketBallIncident.cancel_two_point()

  defp handle_incident(%{type: @two_point, team_id: team_id}, data, home_team_id)
       when team_id == home_team_id,
       do: update_score_data_by(data, :home, +2)

  defp handle_incident(%{type: @two_point}, data, _home_team_id),
    do: update_score_data_by(data, :away, +2)

  defp handle_incident(%{type: @cancel_two_point, team_id: team_id}, data, home_team_id)
       when team_id == home_team_id,
       do: update_score_data_by(data, :home, -2)

  defp handle_incident(%{type: @cancel_two_point}, data, _home_team_id),
    do: update_score_data_by(data, :away, -2)

  @three_point BasketBallIncident.three_point()
  @cancel_three_point BasketBallIncident.cancel_three_point()

  defp handle_incident(%{type: @three_point, team_id: team_id}, data, home_team_id)
       when team_id == home_team_id,
       do: update_score_data_by(data, :home, +3)

  defp handle_incident(%{type: @three_point}, data, _home_team_id),
    do: update_score_data_by(data, :away, +3)

  defp handle_incident(%{type: @cancel_three_point, team_id: team_id}, data, home_team_id)
       when team_id == home_team_id,
       do: update_score_data_by(data, :home, -3)

  defp handle_incident(%{type: @cancel_three_point}, data, _home_team_id),
    do: update_score_data_by(data, :away, -3)

  defp handle_incident(_incident, data, _home_team_id), do: data

  @spec update_score_data_by(data :: t(), team :: :home | :away, points :: integer()) :: t()
  defp update_score_data_by(%__MODULE__{} = data, team, points) do
    score = update_score_by(data.score, team, points)
    [period_score | rest] = data.period_scores
    period_score = update_score_by(period_score, team, points)
    %{data | score: score, period_scores: [period_score | rest]}
  end

  @spec update_score_by(HomeAwayStat.t(), :home | :away, integer()) :: HomeAwayStat.t()
  defp update_score_by(score, team, points) do
    current = Map.get(score, team)
    Map.put(score, team, current + points)
  end
end
