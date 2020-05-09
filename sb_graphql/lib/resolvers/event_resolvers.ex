defmodule SbGraphql.Resolvers.EventResolvers do
  alias State.{Lists, EventWorker}

  def events(_, %{operator_id: operator_id} = args, _) do
    events =
      operator_id
      |> Lists.get_all_event_ids(args[:filters])
      |> Enum.take(5)
      |> Enum.map(fn event_id -> EventWorker.get_event_data(event_id, operator_id) end)

    {:ok, events}
  end
end
