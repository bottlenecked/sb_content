defmodule DiffEngine.Change.LiveData.SoccerLiveDataDiff do
  alias DiffEngine.LiveDataDiff
  alias Model.LiveData.SoccerLiveData
  alias DiffEngine.Change.NoChange

  alias DiffEngine.Change.LiveData.Soccer.{
    SoccerClockChanged,
    SoccerScoreChanged,
    SoccerRedCardsChanged,
    SoccerYellowCardsChanged,
    SoccerCornersChanged
  }

  defimpl LiveDataDiff, for: SoccerLiveData do
    def diff(prev_data, next_data, ev_id) do
      [
        &diff_clock/2,
        &diff_score/2,
        &diff_red_cards/2,
        &diff_yellow_cards/2,
        &diff_corners/2
      ]
      |> Enum.map(fn fun -> fun.(prev_data, next_data) end)
      |> Enum.filter(fn diff -> diff != NoChange.value() end)
      |> Enum.map(fn result -> %{result | event_id: ev_id} end)
    end

    def diff_clock(prev_data, next_data) do
      %{current_period: cp2, total_ellapsed_seconds: ts2, correct_at: ca2, time_ticking?: tt2} =
        next_data

      case prev_data do
        %{current_period: ^cp2, total_ellapsed_seconds: ^ts2, time_ticking?: ^tt2} ->
          NoChange.value()

        _ ->
          %SoccerClockChanged{
            current_period: cp2,
            total_ellapsed_seconds: ts2,
            correct_at: ca2,
            time_ticking?: tt2
          }
      end
    end

    def diff_score(%{score: old_value}, %{score: new_value}) when old_value == new_value,
      do: NoChange.value()

    def diff_score(_, %{score: new_value}) do
      %SoccerScoreChanged{
        score: new_value
      }
    end

    def diff_red_cards(%{red_cards: old_value}, %{red_cards: new_value})
        when old_value == new_value,
        do: NoChange.value()

    def diff_red_cards(_, %{red_cards: new_value}) do
      %SoccerRedCardsChanged{
        red_cards: new_value
      }
    end

    def diff_yellow_cards(%{yellow_cards: old_value}, %{yellow_cards: new_value})
        when old_value == new_value,
        do: NoChange.value()

    def diff_yellow_cards(_, %{yellow_cards: new_value}) do
      %SoccerYellowCardsChanged{
        yellow_cards: new_value
      }
    end

    def diff_corners(%{corners: old_value}, %{corners: new_value}) when old_value == new_value,
      do: NoChange.value()

    def diff_corners(_, %{corners: new_value}) do
      %SoccerCornersChanged{
        corners: new_value
      }
    end
  end
end
