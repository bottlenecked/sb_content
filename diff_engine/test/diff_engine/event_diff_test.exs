defmodule DiffEngine.EventDiffTest do
  use ExUnit.Case, async: true
  alias Model.Event
  alias DiffEngine.EventDiff
  alias DiffEngine.Result.{NoDiff, StartTimeChanged}

  test "start time diff" do
    now = DateTime.utc_now()
    prev = %Event{start_time: now}
    next = %Event{start_time: now}

    diff = EventDiff.diff_start_time(prev, next)

    assert diff == NoDiff.value()

    new_time = DateTime.add(now, 10)
    next = %Event{start_time: new_time}

    diff = EventDiff.diff_start_time(prev, next)

    assert %StartTimeChanged{new_start_time: ^new_time} = diff
  end
end
