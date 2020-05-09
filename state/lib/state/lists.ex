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

  def get_all_event_ids(operator_id, filters) when not is_nil(operator_id) do
    {pattern, guards} = filters_to_match_specs(filters)

    Registry.select(State.EventWorker.registry_name(), [
      {{{:event, :"$1", operator_id}, :_, pattern}, guards, [:"$1"]}
    ])
  end

  def filters_to_match_specs(filters) when is_nil(filters) or map_size(filters) == 0, do: {:_, []}

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
      guard_clauses(var, values)
    }
  end

  def guard_clauses(variable, values) do
    clauses =
      values
      |> Enum.map(fn value -> {:"=:=", variable, value} end)

    List.to_tuple([:orelse | clauses])
  end
end
