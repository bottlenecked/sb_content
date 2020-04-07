defmodule DiffEngine.LiveData.SoccerLiveDataDiffTest do
  use ExUnit.Case, async: true

  alias Model.LiveData.SoccerLiveData
  alias DiffEngine.LiveDataDiff

  test "clock status diff" do
    prev = %SoccerLiveData{
      current_period: 1,
      time_ticking?: true,
      correct_at: DateTime.utc_now(),
      total_ellapsed_seconds: 1890
    }

    assert [] == LiveDataDiff.diff(prev, prev)
  end
end
