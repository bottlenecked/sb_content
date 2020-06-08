defmodule Geneity.Parser.SelectionParser do
  alias Model.Selection

  def handle_event(:start_element, {"Seln", attributes}, state) do
    fields =
      attributes
      |> Enum.reduce([], fn
        {"seln_id", id}, acc ->
          [{:id, id} | acc]

        {"status", status}, acc ->
          [{:active?, status == "A"} | acc]

        {"seln_sort", type}, acc ->
          [{:type_id, type} | acc]

        {"handicap", handicap}, acc ->
          {modifier, _} = Float.parse(handicap)
          [{:modifier, modifier} | acc]

        _, acc ->
          acc
      end)

    # geneity does not set the displayed attribute on selections,
    # but we need to support it in our system, so we set it always to true
    fields = [{:displayed?, true} | fields]

    selection = struct!(Selection, fields)
    %{markets: [market | rest_markets]} = state
    market = %{market | selections: [selection | market.selections]}
    {:ok, %{state | markets: [market | rest_markets]}}
  end

  def handle_event(:start_element, {"Price", attributes}, state) do
    %{markets: [%{selections: [selection | rest_selections]} = market | rest_markets]} = state

    selection =
      attributes
      |> Enum.reduce(selection, fn
        {"dec_prc", decimal_price}, acc ->
          {price, _} = Float.parse(decimal_price)
          %{acc | price_decimal: price}

        _, acc ->
          acc
      end)

    market = %{market | selections: [selection | rest_selections]}
    {:ok, %{state | markets: [market | rest_markets]}}
  end

  def handle_event(:end_element, "Mkt", state) do
    %{markets: [market | rest]} = state
    %{selections: selections} = market

    selections =
      selections
      |> Enum.reverse()
      |> Enum.with_index()
      |> Enum.map(fn {seln, index} -> %{seln | order: index} end)

    market = %{market | selections: selections}

    {:ok, %{state | markets: [market | rest]}}
  end

  def handle_event(_, _, state), do: {:ok, state}
end
