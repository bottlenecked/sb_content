defmodule DiffEngine do
  alias Model.Event

  alias DiffEngine.{EventDiff, LiveDataDiff}

  @spec diff(Event.t(), Event.t()) :: list(struct())
  def diff(old_event, new_event) do
    [
      &EventDiff.diff/2,
      &LiveDataDiff.diff/2
    ]
    |> Enum.map(fn fun -> fun.(old_event, new_event) end)
    |> Enum.flat_map(& &1)
  end
end
