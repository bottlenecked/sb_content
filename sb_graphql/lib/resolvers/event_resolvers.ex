defmodule SbGraphql.Resolvers.EventResolvers do
  alias State.{Search, EventWorker}

  def events(_parent, %{operator_id: operator_id} = args, _res) do
    # default value for arguments does not work as expected, fix after
    # TODO: remove the <args.filters || %{}> after https://github.com/absinthe-graphql/absinthe/issues/939
    # is fixed
    events =
      operator_id
      |> Search.get_event_pids(args[:filters] || %{})
      |> Task.async_stream(
        fn pid ->
          try do
            EventWorker.get_event_data(pid)
          catch
            # based on the Registry documentation, an entry can persist for a little time before it gets
            # cleaned up after the process's death. This should help catch these errors
            :exit, {:noproc, _} -> nil
          end
        end,
        max_concurrency: 100
      )
      |> Enum.map(fn
        {:ok, data} -> data
        _ -> nil
      end)
      |> Enum.filter(fn data -> data != nil end)
      |> Enum.sort_by(fn evt -> evt.display_order end)

    {:ok, events}
  end
end
