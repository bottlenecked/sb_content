defmodule DiffEngine.Result.LiveData.SoccerLiveDataDiff do
  alias DiffEngine.LiveDataDiff
  alias Model.LiveData.SoccerLiveData
  alias DiffEngine.Result.NoDiff
  alias DiffEngine.Result.LiveData.Soccer.SoccerClockChanged

  defimpl LiveDataDiff, for: SoccerLiveData do
    def diff(prev_data, next_data, ev_id) do
      [
        &diff_clock/2
      ]
      |> Enum.map(fn fun -> fun.(prev_data, next_data) end)
      |> Enum.filter(fn diff -> diff != NoDiff.value() end)
      |> Enum.map(fn result -> %{result | event_id: ev_id} end)
    end

    def diff_clock(prev, next) do
      %{current_period: cp2, total_ellapsed_seconds: ts2, correct_at: ca2, time_ticking?: tt2} =
        next

      case prev do
        %{current_period: ^cp2, total_ellapsed_seconds: ^ts2, time_ticking?: ^tt2} ->
          NoDiff.value()

        _ ->
          %SoccerClockChanged{
            current_period: cp2,
            total_ellapsed_seconds: ts2,
            correct_at: ca2,
            time_ticking?: tt2
          }
      end
    end
  end
end
