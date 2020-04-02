defmodule DiffEngine.EventDiff do
  @moduledoc """
  Diffs top level event properties
  """

  alias DiffEngine.Result.{NoDiff, StartTimeChanged}

  def diff(old_event, new_event) do
    [
      &diff_start_time/2
    ]
    |> Enum.map(fn fun -> fun.(old_event, new_event) end)
    |> Enum.filter(fn result -> result != NoDiff.value() end)
  end

  def diff_start_time(%{start_time: old_start_time}, %{start_time: new_start_time})
      when old_start_time == new_start_time,
      do: NoDiff.value()

  def diff_start_time(_, %{start_time: start_time, id: id}),
    do: %StartTimeChanged{event_id: id, new_start_time: start_time}
end
