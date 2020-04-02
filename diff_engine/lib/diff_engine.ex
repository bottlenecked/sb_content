defmodule DiffEngine do
  alias Model.Event

  @spec diff(Event.t(), Event.t()) :: list(map())
  def diff(old_event, new_event) do
  end
end
