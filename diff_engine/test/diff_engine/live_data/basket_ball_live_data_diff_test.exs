defmodule DiffEngine.LiveData.BasketBallLiveDataDiffTest do
  use ExUnit.Case, async: true

  alias Model.LiveData.HomeAwayStat
  alias Model.LiveData.BasketBallLiveData
  alias DiffEngine.LiveDataDiff

  alias DiffEngine.Change.LiveData.BasketBall.{
    BasketBallClockChanged,
    BasketBallScoreChanged,
    BasketBallPeriodScoresChanged
  }

  test "clock status diff" do
    prev = %BasketBallLiveData{
      current_period: 1,
      time_ticking?: true,
      correct_at: DateTime.utc_now(),
      remaining_seconds_in_period: 120
    }

    assert [] == LiveDataDiff.diff(prev, prev)

    [
      current_period: 2,
      time_ticking?: false,
      remaining_seconds_in_period: 110
    ]
    |> Enum.map(fn {key, val} -> Map.put(prev, key, val) end)
    |> Enum.each(fn next ->
      assert [%BasketBallClockChanged{}] = LiveDataDiff.diff(prev, next)
    end)
  end

  test "score diff" do
    prev = %BasketBallLiveData{
      score: %HomeAwayStat{
        home: 1,
        away: 2
      }
    }

    assert [] == LiveDataDiff.diff(prev, prev)

    next = %BasketBallLiveData{
      score: %HomeAwayStat{
        home: 2,
        away: 2
      }
    }

    assert [
             %BasketBallScoreChanged{
               score: %HomeAwayStat{
                 home: 2,
                 away: 2
               }
             }
           ] = LiveDataDiff.diff(prev, next)
  end

  test "period scores diff" do
    prev = %BasketBallLiveData{
      period_scores: [
        %HomeAwayStat{
          home: 1,
          away: 2
        },
        %HomeAwayStat{
          home: 4,
          away: 5
        }
      ]
    }

    assert [] == LiveDataDiff.diff(prev, prev)

    next = %BasketBallLiveData{
      period_scores: [
        %HomeAwayStat{
          home: 1,
          away: 2
        },
        %HomeAwayStat{
          home: 4,
          away: 6
        }
      ]
    }

    next_period_scores = next.period_scores

    assert [
             %BasketBallPeriodScoresChanged{
               period_scores: ^next_period_scores
             }
           ] = LiveDataDiff.diff(prev, next)
  end
end
