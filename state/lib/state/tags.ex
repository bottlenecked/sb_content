defmodule State.Tags do
  @moduledoc """
  tag/2 functions inside this module are meant to only be called from inside an EventWorker's process loop
  """

  alias DiffEngine.Change.EventDiscovered
  alias DiffEngine.Change.Event.{LiveStatusChanged, StatusChanged, VisibilityChanged}
  alias Model.Event

  @registry State.EventWorker.registry_name()

  def tag(name, %EventDiscovered{event: %Event{} = event}) do
    keys = [:live?, :sport_id, :zone_id, :league_id, :active?, :displayed?]

    event
    |> Map.take(keys)
    |> set(name)
  end

  def tag(name, %LiveStatusChanged{live?: value}), do: update(name, :live?, value)
  def tag(name, %StatusChanged{active?: value}), do: update(name, :active?, value)
  def tag(name, %VisibilityChanged{displayed?: value}), do: update(name, :displayed?, value)

  def tag(_, _), do: :ok

  defp set(value, name), do: Registry.update_value(@registry, name, fn _ -> value end)

  def update(name, key, value),
    do: Registry.update_value(@registry, name, fn map -> Map.put(map, key, value) end)
end
