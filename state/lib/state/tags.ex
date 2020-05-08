defmodule State.Tags do
  @moduledoc """
  tag/1 functions inside this module are meant to only be called from inside an EventWorker's process loop
  """

  alias DiffEngine.Change.EventDiscovered
  alias DiffEngine.Change.Event.{LiveStatusChanged, StatusChanged, VisibilityChanged}
  alias Model.Event

  @registry State.EventWorker.registry_name()

  def tag(%EventDiscovered{event: %Event{} = event}) do
    keys = [:live?, :sport_id, :zone_id, :league_id, :active?, :displayed?]

    event
    |> Map.take(keys)
    |> Enum.each(fn {key, value} -> register(key, value) end)
  end

  def tag(%LiveStatusChanged{live?: value}), do: re_register(:live?, value)
  def tag(%StatusChanged{active?: value}), do: re_register(:active?, value)
  def tag(%VisibilityChanged{displayed?: value}), do: re_register(:displayed?, value)

  def tag(_), do: :ok

  defp register(tag, value), do: Registry.register(@registry, tag, value)

  defp re_register(tag, value) do
    Registry.unregister(@registry, tag)
    register(tag, value)
  end
end
