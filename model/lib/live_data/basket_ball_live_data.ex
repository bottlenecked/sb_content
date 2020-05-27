defmodule Model.LiveData.BasketBallLiveData do
  alias Model.LiveData.{HomeAwayStat, Incident}
  alias Model.LiveData.IncidentType.{CommonIncident, BasketBallIncident}

  @zero_stat %HomeAwayStat{}

  @type t() :: %__MODULE__{}

  defstruct [
    :current_period,
    :total_ellapsed_seconds,
    :correct_at,
    :regular_period_length,
    :extra_period_length,
    :time_ticking?,
    score: @zero_stat,
    period_scores: [],
    incidents: []
  ]

  @spec update_live_data(list(Incident.t()), t(), integer()) :: t()
  def update_live_data(
        incidents_asc,
        %__MODULE__{} = data,
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
    put_in(data.current_period, data.current_period + 1)
    put_in(data.period_scores, [@zero_stat | data.period_scores])
  end

  # points

  @one_point BasketBallIncident.one_point()
  @cancel_one_point BasketBallIncident.cancel_one_point()

  defp handle_incident(%{type: @one_point, team_id: team_id}, data, home_team_id)
       when team_id == home_team_id do
    put_in(data.score.home, data.score.home + 1)
    [period_score | rest] = data.period_scores
    period_score = %{period_score | home: period_score.home + 1}
    put_in(data.period_scores, [period_score | rest])
  end

  defp handle_incident(%{type: @one_point}, data, _home_team_id) do
    put_in(data.score.away, data.score.away + 1)
    [period_score | rest] = data.period_scores
    period_score = %{period_score | away: period_score.away + 1}
    put_in(data.period_scores, [period_score | rest])
  end

  defp handle_incident(%{type: @cancel_one_point, team_id: team_id}, data, home_team_id)
       when team_id == home_team_id do
    put_in(data.score.home, data.score.home - 1)
    [period_score | rest] = data.period_scores
    period_score = %{period_score | home: period_score.home - 1}
    put_in(data.period_scores, [period_score | rest])
  end

  defp handle_incident(%{type: @cancel_one_point}, data, _home_team_id) do
    put_in(data.score.away, data.score.away - 1)
    [period_score | rest] = data.period_scores
    period_score = %{period_score | away: period_score.away - 1}
    put_in(data.period_scores, [period_score | rest])
  end

  @two_point BasketBallIncident.two_point()
  @cancel_two_point BasketBallIncident.cancel_two_point()

  defp handle_incident(%{type: @two_point, team_id: team_id}, data, home_team_id)
       when team_id == home_team_id do
    put_in(data.score.home, data.score.home + 2)
    [period_score | rest] = data.period_scores
    period_score = %{period_score | home: period_score.home + 2}
    put_in(data.period_scores, [period_score | rest])
  end

  defp handle_incident(%{type: @two_point}, data, _home_team_id) do
    put_in(data.score.away, data.score.away + 2)
    [period_score | rest] = data.period_scores
    period_score = %{period_score | away: period_score.away + 2}
    put_in(data.period_scores, [period_score | rest])
  end

  defp handle_incident(%{type: @cancel_two_point, team_id: team_id}, data, home_team_id)
       when team_id == home_team_id do
    put_in(data.score.home, data.score.home - 2)
    [period_score | rest] = data.period_scores
    period_score = %{period_score | home: period_score.home - 2}
    put_in(data.period_scores, [period_score | rest])
  end

  defp handle_incident(%{type: @cancel_two_point}, data, _home_team_id) do
    put_in(data.score.away, data.score.away - 2)
    [period_score | rest] = data.period_scores
    period_score = %{period_score | away: period_score.away - 2}
    put_in(data.period_scores, [period_score | rest])
  end

  @three_point BasketBallIncident.three_point()
  @cancel_three_point BasketBallIncident.cancel_three_point()

  defp handle_incident(%{type: @three_point, team_id: team_id}, data, home_team_id)
       when team_id == home_team_id do
    put_in(data.score.home, data.score.home + 3)
    [period_score | rest] = data.period_scores
    period_score = %{period_score | home: period_score.home + 3}
    put_in(data.period_scores, [period_score | rest])
  end

  defp handle_incident(%{type: @three_point}, data, _home_team_id) do
    put_in(data.score.away, data.score.away + 3)
    [period_score | rest] = data.period_scores
    period_score = %{period_score | away: period_score.away + 3}
    put_in(data.period_scores, [period_score | rest])
  end

  defp handle_incident(%{type: @cancel_three_point, team_id: team_id}, data, home_team_id)
       when team_id == home_team_id do
    put_in(data.score.home, data.score.home - 3)
    [period_score | rest] = data.period_scores
    period_score = %{period_score | home: period_score.home - 3}
    put_in(data.period_scores, [period_score | rest])
  end

  defp handle_incident(%{type: @cancel_three_point}, data, _home_team_id) do
    put_in(data.score.away, data.score.away - 3)
    [period_score | rest] = data.period_scores
    period_score = %{period_score | away: period_score.away - 3}
    put_in(data.period_scores, [period_score | rest])
  end

  defp handle_incident(_incident, data, _home_team_id), do: data
end
