defmodule SbGraphql.Schema.EventSubscriptionTypes do
  use Absinthe.Schema.Notation
  import SbGraphql.Schema.Helpers.Macros, only: [import_types_under: 1]
  alias SbGraphql.Schema.Helpers

  import_types_under("./lib/schema/event_subscription_types/")

  union :change do
    types([
      :event_removed,
      :status_changed
    ])

    resolve_type(fn
      %_change{} = change, _ -> Helpers.convert_change_to_subscription(change)
      _, _ -> nil
    end)
  end

  object :event_subscriptions do
    @desc "subscribe to changes in events"
    field :changes, list_of(:change) do
      @desc "only subscribe to changes for a specific operator. If left empty default will be 'stoiximan_gr'"
      arg(:operator_id, :id, default_value: "stoiximan_gr")

      @desc "list of event ids to listen to changes for. If left empty will subscribe to changes for all events"
      arg(:event_id, list_of(:id), default_value: ["*"])

      config(fn args, _info ->
        topics =
          args.event_id
          |> Enum.map(fn ev_id ->
            "#{args.operator_id}/#{ev_id}"
          end)

        {:ok, topic: topics, context_id: "global"}
      end)
    end
  end
end
