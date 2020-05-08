defmodule DiffEngine.LiveData.SoccerLiveDataDiffTest do
  use ExUnit.Case, async: true

  alias Model.LiveData.HomeAwayStat
  alias Model.LiveData.SoccerLiveData
  alias DiffEngine.LiveDataDiff

  alias DiffEngine.Change.LiveData.Soccer.{
    SoccerClockChanged,
    SoccerScoreChanged,
    SoccerRedCardsChanged,
    SoccerYellowCardsChanged,
    SoccerCornersChanged
  }

  test "clock status diff" do
    prev = %SoccerLiveData{
      current_period: 1,
      time_ticking?: true,
      correct_at: DateTime.utc_now(),
      total_ellapsed_seconds: 1890
    }

    assert [] == LiveDataDiff.diff(prev, prev)

    [
      current_period: 2,
      time_ticking?: false,
      total_ellapsed_seconds: 1900
    ]
    |> Enum.map(fn {key, val} -> Map.put(prev, key, val) end)
    |> Enum.each(fn next ->
      assert [%SoccerClockChanged{}] = LiveDataDiff.diff(prev, next)
    end)
  end

  test "score diff" do
    prev = %SoccerLiveData{
      score: %HomeAwayStat{
        home: 1,
        away: 2
      }
    }

    assert [] == LiveDataDiff.diff(prev, prev)

    next = %SoccerLiveData{
      score: %HomeAwayStat{
        home: 2,
        away: 2
      }
    }

    assert [
             %SoccerScoreChanged{
               score: %HomeAwayStat{
                 home: 2,
                 away: 2
               }
             }
           ] = LiveDataDiff.diff(prev, next)
  end

  test "yellow cards diff" do
    prev = %SoccerLiveData{
      yellow_cards: %HomeAwayStat{
        home: 1,
        away: 2
      }
    }

    assert [] == LiveDataDiff.diff(prev, prev)

    next = %SoccerLiveData{
      yellow_cards: %HomeAwayStat{
        home: 2,
        away: 2
      }
    }

    assert [
             %SoccerYellowCardsChanged{
               yellow_cards: %HomeAwayStat{
                 home: 2,
                 away: 2
               }
             }
           ] = LiveDataDiff.diff(prev, next)
  end

  test "red cards diff" do
    prev = %SoccerLiveData{
      red_cards: %HomeAwayStat{
        home: 1,
        away: 2
      }
    }

    assert [] == LiveDataDiff.diff(prev, prev)

    next = %SoccerLiveData{
      red_cards: %HomeAwayStat{
        home: 2,
        away: 2
      }
    }

    assert [
             %SoccerRedCardsChanged{
               red_cards: %HomeAwayStat{
                 home: 2,
                 away: 2
               }
             }
           ] = LiveDataDiff.diff(prev, next)
  end

  test "corners diff" do
    prev = %SoccerLiveData{
      corners: %HomeAwayStat{
        home: 1,
        away: 2
      }
    }

    assert [] == LiveDataDiff.diff(prev, prev)

    next = %SoccerLiveData{
      corners: %HomeAwayStat{
        home: 2,
        away: 2
      }
    }

    assert [
             %SoccerCornersChanged{
               corners: %HomeAwayStat{
                 home: 2,
                 away: 2
               }
             }
           ] = LiveDataDiff.diff(prev, next)
  end
end
