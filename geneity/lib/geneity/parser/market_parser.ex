defmodule Geneity.Parser.MarketParser do
  alias Model.Market

  def handle_event(:start_element, {"Mkt", attributes}, state) do
    fields =
      attributes
      |> Enum.reduce([], fn
        {"mkt_id", id}, acc ->
          [{:id, String.to_integer(id)} | acc]

        {"status", status}, acc ->
          [{:active?, status == "A"} | acc]

        {"mkt_sort", type}, acc ->
          [{:type_id, type} | acc]

        {"handicap", handicap}, acc ->
          {modifier, _} = Float.parse(handicap)
          [{:modifier, modifier} | acc]

        _, acc ->
          acc
      end)

    market = struct!(Market, fields)
    {:ok, %{state | markets: [market | state.markets]}}
  end

  def handle_event(:end_element, "Mkt", state) do
    %{markets: [market | rest]} = state
    %{selections: selections} = market

    selections = Enum.reverse(selections)
    market = %{market | selections: selections}

    {:ok, %{state | markets: [market | rest]}}
  end

  def handle_event(:end_element, "Ev", state) do
    %{markets: markets} = state
    {:ok, %{state | markets: Enum.reverse(markets)}}
  end

  def handle_event(_type, _data, state), do: {:ok, state}
end
