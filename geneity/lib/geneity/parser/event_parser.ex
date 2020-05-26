defmodule Geneity.Parser.EventParser do
  @behaviour Saxy.Handler

  def handle_event(:start_element, {"Sport", attributes}, state) do
    state =
      attributes
      |> Enum.reduce(state, fn
        {"sport_code", id}, acc ->
          %{acc | sport_id: id}

        {"disporder", value}, acc ->
          # global display order needs to preserve importance of sport->zone->league->event display order
          %{acc | display_order: String.to_integer(value) * 100_000_000}

        _, acc ->
          acc
      end)

    {:ok, state}
  end

  def handle_event(:start_element, {"SBClass", attributes}, state) do
    state =
      attributes
      |> Enum.reduce(state, fn
        {"sb_class_id", id}, acc ->
          %{acc | zone_id: String.to_integer(id)}

        {"disporder", value}, acc ->
          order = String.to_integer(value) * 10_000_000
          %{acc | display_order: acc.display_order + order}

        _, acc ->
          acc
      end)

    {:ok, state}
  end

  def handle_event(:start_element, {"SBType", attributes}, state) do
    state =
      attributes
      |> Enum.reduce(state, fn
        {"sb_type_id", id}, acc ->
          %{acc | league_id: String.to_integer(id)}

        {"disporder", value}, acc ->
          order = String.to_integer(value) * 1_000_000
          %{acc | display_order: acc.display_order + order}

        _, acc ->
          acc
      end)

    {:ok, state}
  end

  def handle_event(:start_element, {"Ev", attributes}, state) do
    state =
      attributes
      |> Enum.reduce(state, fn
        {"ev_id", id}, acc ->
          %{acc | id: String.to_integer(id)}

        {"start_time", time}, acc ->
          {:ok, start_time, 0} = DateTime.from_iso8601(time <> "Z")
          %{acc | start_time: start_time}

        {"inplay_now", inplay}, acc ->
          %{acc | live?: inplay == "Y"}

        {"status", status}, acc ->
          %{acc | active?: status == "A"}

        {"disporder", value}, acc ->
          order = String.to_integer(value)
          %{acc | display_order: acc.display_order + order}

        _, acc ->
          acc
      end)

    {:ok, state}
  end

  def handle_event(:start_element, {"EvDetail", attributes}, state) do
    state =
      attributes
      |> Enum.reduce(state, fn
        {"br_match_id", id}, acc -> %{acc | br_match_id: String.to_integer(id)}
        _, acc -> acc
      end)

    {:ok, state}
  end

  def handle_event(_, _, state), do: {:ok, state}
end
