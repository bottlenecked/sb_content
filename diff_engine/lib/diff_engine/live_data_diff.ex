defprotocol DiffEngine.LiveDataDiff do
  @doc """
  Diffs and returns changes in an event's live data
  """
  @fallback_to_any true
  def diff(old_live_data, new_live_data, ev_id \\ 0)
end

defimpl DiffEngine.LiveDataDiff, for: Model.Event do
  def diff(%{live_data: prev}, %{live_data: next}, _ev_id),
    do: DiffEngine.LiveDataDiff.diff(prev, next, prev.id)
end

defimpl DiffEngine.LiveDataDiff, for: Any do
  def diff(_, _, _), do: DiffEngine.Result.NoDiff.value()
end
