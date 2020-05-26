defmodule State.Lists do
  @moduledoc """
  Find event ids by common characteristics
  """

  # Registry.select(State.EventWorker.registry_name(), [{{:"$1", :"$2", :"$3"}, [], [{{:"$1", :"$2", :"$3"}}]}])

  # returns a list of [{key, pid, value}] like
  # [...., {{:event, 5175146, "stoiximan_gr"} = key, PID<0.1751.0>,  %{
  #    active?: true,
  #    displayed?: true,
  #    league_id: 186583,
  #    live?: false,
  #    sport_id: "TENN",
  #    zone_id: 11537
  #  } = value}, ...]

  def get_all_event_ids(operator_id, %{event_id: _values} = filters)
      when not is_nil(operator_id) do
    filters = normalize_filters(filters)
    guard = guard_clause(:"$1", filters.event_id)

    Registry.select(State.EventWorker.registry_name(), [
      {{{:event, :"$1", operator_id}, :_, :_}, [guard], [:"$1"]}
    ])
  end

  def get_all_event_ids(operator_id, filters) when not is_nil(operator_id) do
    {pattern, guards} =
      filters
      |> normalize_filters()
      |> filters_to_match_specs()

    Registry.select(State.EventWorker.registry_name(), [
      {{{:event, :"$1", operator_id}, :_, pattern}, guards, [:"$1"]}
    ])
  end

  def filters_to_match_specs(filters) when map_size(filters) == 0, do: {:_, []}

  def filters_to_match_specs(filters) do
    {pattern, guards} =
      filters
      |> Enum.with_index(2)
      |> Enum.map(fn
        {{:live, value}, i} -> generate_match_spec(:live?, i, value)
        {{:active, value}, i} -> generate_match_spec(:active?, i, value)
        {{:displayed, value}, i} -> generate_match_spec(:displayed?, i, value)
        {{:sport_id = key, values}, i} -> generate_match_spec(key, i, values)
        {{:zone_id = key, values}, i} -> generate_match_spec(key, i, values)
        {{:league_id = key, values}, i} -> generate_match_spec(key, i, values)
      end)
      |> Enum.reduce({%{}, []}, fn {{key, value}, guard}, {pattern, guards} ->
        {Map.put(pattern, key, value), [guard | guards]}
      end)

    {pattern, List.flatten(guards)}
  end

  def generate_match_spec(key, _i, value) when not is_list(value) do
    {
      {key, value},
      []
    }
  end

  def generate_match_spec(key, i, values) do
    var = :"$#{i}"

    {
      {key, var},
      guard_clause(var, values)
    }
  end

  def guard_clause(variable, values) when is_list(values) do
    clauses =
      values
      |> Enum.map(fn value -> guard_clause(variable, value) end)

    List.to_tuple([:orelse | clauses])
  end

  def guard_clause(variable, value), do: {:"=:=", variable, value}

  defp normalize_filters(filters) do
    filters
    |> Enum.filter(fn {key, _value} -> key in [:event_id, :zone_id, :league_id] end)
    |> Enum.map(&fix_ids/1)
    |> Enum.reduce(filters, fn {key, value}, acc -> Map.put(acc, key, value) end)
  end

  defp fix_ids({key, value}) do
    {key, convert_to_ints(value)}
  end

  defp convert_to_ints(value) when is_binary(value) do
    case Integer.parse(value) do
      {int, _} -> int
      _ -> value
    end
  end

  defp convert_to_ints(values) when is_list(values) do
    values
    |> Enum.map(&convert_to_ints/1)
  end

  defp convert_to_ints(value), do: value
end
