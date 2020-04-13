defmodule DiffEngine.SelectionDiff do
  alias Model.{Market, Selection}
  alias DiffEngine.Result.NoDiff

  alias DiffEngine.Result.Selection.{
    SelectionRemoved,
    SelectionCreated,
    SelectionOrderChanged,
    SelectionStatusChanged,
    SelectionVisibilityChanged,
    SelectionPriceChanged
  }

  def diff(%Market{selections: prev_selections}, %Market{
        id: market_id,
        selections: next_selections
      }) do
    next_selections_map = selections_to_map(next_selections)
    prev_selections_map = selections_to_map(prev_selections)

    removed_selections_results =
      prev_selections
      |> detect_missing_selections(next_selections_map)
      |> Enum.map(fn seln -> %SelectionRemoved{selection_id: seln.id} end)

    created_selections_results =
      next_selections
      |> detect_missing_selections(prev_selections_map)
      |> Enum.map(fn seln -> %SelectionCreated{selection: seln} end)

    # lastly grab all selections present both before and afterwards
    # and run all checks on each one

    selection_pairs =
      prev_selections
      |> Enum.map(fn seln -> {seln, Map.get(next_selections_map, seln.id)} end)
      |> Enum.filter(fn {_prev, next} -> next != nil end)

    comparison_funs = [
      &diff_order/2,
      &diff_status/2,
      &diff_visibility/2,
      &diff_price/2
    ]

    comparison_results =
      for {prev_selections, next_selection} <- selection_pairs,
          comparison_fun <- comparison_funs do
        comparison_fun.(prev_selections, next_selection)
      end
      |> Enum.filter(fn res -> res != NoDiff.value() end)

    (removed_selections_results ++ created_selections_results ++ comparison_results)
    |> Enum.map(fn result -> %{result | market_id: market_id} end)
  end

  def diff_order(%Selection{order: prev_value}, %Selection{order: next_value})
      when prev_value == next_value,
      do: NoDiff.value()

  def diff_order(_prev, %Selection{order: next_value, id: id}),
    do: %SelectionOrderChanged{selection_id: id, order: next_value}

  def diff_status(%Selection{active?: prev_value}, %Selection{active?: next_value})
      when prev_value == next_value,
      do: NoDiff.value()

  def diff_status(_prev, %Selection{active?: next_value, id: id}),
    do: %SelectionStatusChanged{selection_id: id, active?: next_value}

  def diff_visibility(%Selection{displayed?: prev_value}, %Selection{displayed?: next_value})
      when prev_value == next_value,
      do: NoDiff.value()

  def diff_visibility(_prev, %Selection{displayed?: next_value, id: id}),
    do: %SelectionVisibilityChanged{selection_id: id, displayed?: next_value}

  def diff_price(%Selection{price_decimal: prev_value}, %Selection{price_decimal: next_value})
      when prev_value == next_value,
      do: NoDiff.value()

  def diff_price(_prev, %Selection{price_decimal: next_value, id: id}),
    do: %SelectionPriceChanged{selection_id: id, price_decimal: next_value}

  defp detect_missing_selections(base_line, target) do
    base_line
    |> Enum.filter(fn seln -> !Map.has_key?(target, seln.id) end)
  end

  defp selections_to_map(selections) do
    selections
    |> Enum.map(fn seln -> {seln.id, seln} end)
    |> Map.new()
  end
end
