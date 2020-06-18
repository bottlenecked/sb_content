defmodule SbGraphql.Schema.EventSubscriptionTypes.EventStatusChangedType do
  use Absinthe.Schema.Notation

  import SbGraphql.Resolvers.IdentifierResolvers, only: [resolve_to_property: 1]

  @desc "event status has changed between active / inactive"
  object :status_changed do
    field(:event_id, :id)

    field(:active, :boolean) do
      resolve(resolve_to_property(:active?))
    end
  end
end
