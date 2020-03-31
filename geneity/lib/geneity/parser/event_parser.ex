defmodule Geneity.Parser.EventParser do
  @behaviour Saxy.Handler

  alias Geneity.Parser.{MarketParser, SelectionParser}

  def handle_event(:start_element, {"Sport", attributes}, state) do
    state =
      attributes
      |> Enum.reduce(state, fn
        {"sport_code", id}, acc -> %{acc | sport_id: id}
        _, acc -> acc
      end)

    {:ok, state}
  end

  def handle_event(:start_element, {"SBClass", attributes}, state) do
    state =
      attributes
      |> Enum.reduce(state, fn
        {"sb_class_id", id}, acc -> %{acc | zone_id: String.to_integer(id)}
        _, acc -> acc
      end)

    {:ok, state}
  end

  def handle_event(:start_element, {"SBType", attributes}, state) do
    state =
      attributes
      |> Enum.reduce(state, fn
        {"sb_type_id", id}, acc -> %{acc | league_id: String.to_integer(id)}
        _, acc -> acc
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

        {"disporder", order}, acc ->
          %{acc | display_order: String.to_integer(order)}

        _, acc ->
          acc
      end)

    {:ok, state}
  end

  def handle_event(:end_element, "Ev", state) do
    %{markets: markets} = state
    {:ok, %{state | markets: Enum.reverse(markets)}}
  end

  def handle_event(type, data, state) do
    {:ok, state} = MarketParser.handle_event(type, data, state)
    {:ok, state} = SelectionParser.handle_event(type, data, state)
    {:ok, state}
  end
end
