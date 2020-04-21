defmodule DiffEngine do
  alias Model.Event

  alias DiffEngine.{EventDiff, LiveDataDiff, MarketDiff}
  alias DiffEngine.Result.EventDiscovered

  @spec diff(Event.t() | nil, Event.t()) :: list(struct())
  def diff(old_event, new_event)

  def diff(nil, new_event) do
    [%EventDiscovered{event_id: new_event.id, event: new_event}]
  end

  def diff(old_event, new_event) do
    [
      &EventDiff.diff/2,
      &LiveDataDiff.diff/2,
      &MarketDiff.diff/2
    ]
    |> Enum.map(fn fun -> fun.(old_event, new_event) end)
    |> Enum.flat_map(& &1)
  end
end
