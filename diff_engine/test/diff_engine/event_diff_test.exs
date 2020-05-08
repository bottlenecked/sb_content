defmodule DiffEngine.EventDiffTest do
  use ExUnit.Case, async: true
  alias Model.Event
  alias DiffEngine.EventDiff

  alias DiffEngine.Change.NoChange

  alias DiffEngine.Change.Event.{
    StartTimeChanged,
    StatusChanged,
    LiveStatusChanged,
    DisplayOrderChanged,
    VisibilityChanged
  }

  test "start time diff" do
    now = DateTime.utc_now()
    prev = %Event{start_time: now}
    next = %Event{start_time: now}

    diff = EventDiff.diff_start_time(prev, next)

    assert diff == NoChange.value()

    new_time = DateTime.add(now, 10)
    next = %Event{start_time: new_time}

    diff = EventDiff.diff_start_time(prev, next)

    assert %StartTimeChanged{start_time: ^new_time} = diff
  end

  test "status diff" do
    prev = %Event{active?: false}
    next = %Event{active?: false}

    diff = EventDiff.diff_status(prev, next)

    assert diff == NoChange.value()

    next = %Event{active?: true}

    diff = EventDiff.diff_status(prev, next)

    assert %StatusChanged{active?: true} = diff
  end

  test "live diff" do
    prev = %Event{live?: false}
    next = %Event{live?: false}

    diff = EventDiff.diff_status(prev, next)

    assert diff == NoChange.value()

    next = %Event{live?: true}

    diff = EventDiff.diff_live_status(prev, next)

    assert %LiveStatusChanged{live?: true} = diff
  end

  test "display order diff" do
    prev = %Event{display_order: 1}
    next = %Event{display_order: 1}

    diff = EventDiff.diff_status(prev, next)

    assert diff == NoChange.value()

    next = %Event{display_order: 2}

    diff = EventDiff.diff_display_order(prev, next)

    assert %DisplayOrderChanged{display_order: 2} = diff
  end

  test "visibility diff" do
    prev = %Event{displayed?: false}
    next = %Event{displayed?: false}

    diff = EventDiff.diff_status(prev, next)

    assert diff == NoChange.value()

    next = %Event{displayed?: true}

    diff = EventDiff.diff_visibility(prev, next)

    assert %VisibilityChanged{displayed?: true} = diff
  end
end
