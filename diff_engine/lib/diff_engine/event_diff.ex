defmodule DiffEngine.EventDiff do
  @moduledoc """
  Diffs top level event properties
  """

  require DiffEngine.Result

  DiffEngine.Result.alias_result_structs()

  def diff(old_event, new_event) do
    [
      &diff_start_time/2,
      &diff_status/2,
      &diff_live_status/2,
      &diff_display_order/2,
      &diff_visibility/2
    ]
    |> Enum.map(fn fun -> fun.(old_event, new_event) end)
    |> Enum.filter(fn result -> result != NoDiff.value() end)
  end

  def diff_start_time(%{start_time: old_value}, %{start_time: new_value})
      when old_value == new_value,
      do: NoDiff.value()

  def diff_start_time(_, %{start_time: new_value, id: id}),
    do: %StartTimeChanged{event_id: id, start_time: new_value}

  def diff_status(%{active?: old_value}, %{active?: new_value})
      when old_value == new_value,
      do: NoDiff.value()

  def diff_status(_, %{active?: new_value, id: id}),
    do: %StatusChanged{event_id: id, active?: new_value}

  def diff_live_status(%{live?: old_value}, %{live?: new_value})
      when old_value == new_value,
      do: NoDiff.value()

  def diff_live_status(_, %{live?: new_value, id: id}),
    do: %LiveStatusChanged{event_id: id, live?: new_value}

  def diff_display_order(%{display_order: old_value}, %{display_order: new_value})
      when old_value == new_value,
      do: NoDiff.value()

  def diff_display_order(_, %{display_order: new_value, id: id}),
    do: %DisplayOrderChanged{event_id: id, display_order: new_value}

  def diff_visibility(%{displayed?: old_value}, %{displayed?: new_value})
      when old_value == new_value,
      do: NoDiff.value()

  def diff_visibility(_, %{displayed?: new_value, id: id}),
    do: %VisibilityChanged{event_id: id, displayed?: new_value}
end
