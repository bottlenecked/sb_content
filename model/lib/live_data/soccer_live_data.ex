defmodule Model.LiveData.SoccerLiveData do
  alias Model.LiveData.{HomeAwayStat, Incident}

  @zero_stat %HomeAwayStat{}

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

    def update_live_data(incidents, %Incident{} = data) do
      data
    end
  end
end
