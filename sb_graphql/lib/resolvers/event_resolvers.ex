defmodule SbGraphql.Resolvers.EventResolvers do
  alias State.{Lists, EventWorker}

  def events(_, %{operator_id: operator_id} = args, _) do
    events =
      operator_id
      |> Lists.get_all_event_ids(args[:filters])
      |> Task.async_stream(fn event_id -> EventWorker.get_event_data(event_id, operator_id) end,
        max_concurrency: 100
      )
      |> Enum.map(fn
        {:ok, data} -> data
        _ -> nil
      end)
      |> Enum.filter(fn data -> data != nil end)

    {:ok, events}
  end
end
