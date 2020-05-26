defmodule SbGraphql.Resolvers.EventResolvers do
  alias State.{Lists, EventWorker}

  def events(_parent, %{operator_id: operator_id, filters: filters} = _args, _res) do
    events =
      operator_id
      |> Lists.get_event_pids(filters)
      |> Task.async_stream(&EventWorker.get_event_data/1, max_concurrency: 100)
      |> Enum.map(fn
        {:ok, data} -> data
        _ -> nil
      end)
      |> Enum.filter(fn data -> data != nil end)
      |> Enum.sort_by(fn evt -> evt.display_order end)

    {:ok, events}
  end
end
