defmodule State.Search do
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

  @registry_name State.EventWorker.registry_name()

  @spec get_event_pids(operator_id :: String.t(), filters :: map()) :: [pid()]
  def get_event_pids(operator_id, filters)

  def get_event_pids(operator_id, %{event_id: [_ev_id]} = filters) do
    # optimize single event_id lookup case

    Registry.lookup(@registry_name, {:event, hd(filters.event_id), operator_id})
    |> Enum.map(fn {pid, _value} -> pid end)
  end

  def get_event_pids(operator_id, %{event_id: _event_ids} = filters) do
    guard = guard_clause(:"$1", filters.event_id)

    Registry.select(@registry_name, [
      {{{:event, :"$1", operator_id}, :"$2", :_}, [guard], [:"$2"]}
    ])
  end

  def get_event_pids(operator_id, filters) do
    {pattern, guards} = filters_to_match_specs(filters)

    Registry.select(@registry_name, [
      {{{:event, :_, operator_id}, :"$1", pattern}, guards, [:"$1"]}
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
end
