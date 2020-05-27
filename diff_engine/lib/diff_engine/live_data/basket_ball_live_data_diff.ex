defmodule DiffEngine.Change.LiveData.BasketBallLiveDataDiff do
  alias DiffEngine.LiveDataDiff
  alias Model.LiveData.BasketBallLiveData
  alias DiffEngine.Change.NoChange

  alias DiffEngine.Change.LiveData.BasketBall.{
    BasketBallClockChanged,
    BasketBallScoreChanged,
    BasketBallPeriodScoresChanged
  }

  defimpl LiveDataDiff, for: BasketBallLiveData do
    def diff(prev_data, next_data, ev_id) do
      [
        &diff_clock/2,
        &diff_score/2,
        &diff_period_scores/2
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
          %BasketBallClockChanged{
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
      %BasketBallScoreChanged{
        score: new_value
      }
    end

    def diff_period_scores(%{period_scores: old_value}, %{period_scores: new_value})
        when old_value == new_value,
        do: NoChange.value()

    def diff_period_scores(_, %{period_scores: new_value}) do
      %BasketBallPeriodScoresChanged{
        period_scores: new_value
      }
    end
  end
end
