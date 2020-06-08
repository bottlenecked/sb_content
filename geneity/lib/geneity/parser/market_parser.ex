defmodule Geneity.Parser.MarketParser do
  alias Model.Market

  def handle_event(:start_element, {"Mkt", attributes}, state) do
    fields =
      attributes
      |> Enum.reduce([], fn
        {"mkt_id", id}, acc ->
          [{:id, id} | acc]

        {"status", status}, acc ->
          [{:active?, status == "A"} | acc]

        {"displayed", displayed}, acc ->
          [{:displayed?, displayed == "Y"} | acc]

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

  def handle_event(:end_element, "Ev", state) do
    %{markets: markets} = state

    markets =
      markets
      |> Enum.reverse()
      |> Enum.with_index()
      |> Enum.map(fn {mkt, idx} -> %{mkt | order: idx} end)

    {:ok, %{state | markets: markets}}
  end

  def handle_event(_type, _data, state), do: {:ok, state}
end
