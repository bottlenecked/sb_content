defmodule Model.LiveData.SoccerLiveData do
  alias Model.LiveData.{HomeAwayStat, Incident}

  @zero_stat %HomeAwayStat{}

  @type t() :: %__MODULE__{}

  defstruct [
    :current_period,
    :period_ellapsed_seconds,
    :correct_at,
    :regular_period_length,
    :extra_period_length,
    :time_ticking?,
    score: @zero_stat,
    red_cards: @zero_stat,
    yellow_cards: @zero_stat,
    corners: @zero_stat,
    incidents: []
  ]

  defmodule IncidentType do
    @types [
      :event_start,
      :event_end,
      :period_start,
      :period_end,
      :goal,
      :cancel_goal,
      :corner,
      :cancel_corner,
      :red_card,
      :cancel_red_card,
      :yellow_card,
      :cancel_yellow_card
    ]

    for type <- @types do
      def unquote(type)(), do: unquote(type)
    end
  end

  @spec update_live_data(list(Incident.t()), t(), integer()) :: t()
  def update_live_data(
        incidents_asc,
        %__MODULE__{} = data,
        home_team_id
      ) do
    incidents_asc
    |> Enum.reduce(data, fn inc, acc -> handle_incident(inc, acc, home_team_id) end)
  end

  # goals

  defp handle_incident(%{type: :goal, team_id: team_id}, data, home_team_id)
       when team_id == home_team_id do
    put_in(data.score.home, data.score.home + 1)
  end

  defp handle_incident(%{type: :goal}, data, _home_team_id) do
    put_in(data.score.away, data.score.away + 1)
  end

  defp handle_incident(%{type: :cancel_goal, team_id: team_id}, data, home_team_id)
       when team_id == home_team_id do
    put_in(data.score.home, data.score.home - 1)
  end

  defp handle_incident(%{type: :cancel_goal}, data, _home_team_id) do
    put_in(data.score.away, data.score.away - 1)
  end

  # corners

  defp handle_incident(%{type: :corner, team_id: team_id}, data, home_team_id)
       when team_id == home_team_id do
    put_in(data.corners.home, data.corners.home + 1)
  end

  defp handle_incident(%{type: :corner}, data, _home_team_id) do
    put_in(data.corners.away, data.corners.away + 1)
  end

  defp handle_incident(%{type: :cancel_corner, team_id: team_id}, data, home_team_id)
       when team_id == home_team_id do
    put_in(data.corners.home, data.corners.home - 1)
  end

  defp handle_incident(%{type: :cancel_corner}, data, _home_team_id) do
    put_in(data.corners.away, data.corners.away - 1)
  end

  # red cards

  defp handle_incident(%{type: :red_card, team_id: team_id}, data, home_team_id)
       when team_id == home_team_id do
    put_in(data.red_cards.home, data.red_cards.home + 1)
  end

  defp handle_incident(%{type: :red_card}, data, _home_team_id) do
    put_in(data.red_cards.away, data.red_cards.away + 1)
  end

  defp handle_incident(%{type: :cancel_red_card, team_id: team_id}, data, home_team_id)
       when team_id == home_team_id do
    put_in(data.red_cards.home, data.red_cards.home - 1)
  end

  defp handle_incident(%{type: :cancel_red_card}, data, _home_team_id) do
    put_in(data.red_cards.away, data.red_cards.away - 1)
  end

  # yellow cards

  defp handle_incident(%{type: :yellow_card, team_id: team_id}, data, home_team_id)
       when team_id == home_team_id do
    put_in(data.yellow_cards.home, data.yellow_cards.home + 1)
  end

  defp handle_incident(%{type: :yellow_card}, data, _home_team_id) do
    put_in(data.yellow_cards.away, data.yellow_cards.away + 1)
  end

  defp handle_incident(%{type: :cancel_yellow_card, team_id: team_id}, data, home_team_id)
       when team_id == home_team_id do
    put_in(data.yellow_cards.home, data.yellow_cards.home - 1)
  end

  defp handle_incident(%{type: :cancel_yellow_card}, data, _home_team_id) do
    put_in(data.yellow_cards.away, data.yellow_cards.away - 1)
  end
end
