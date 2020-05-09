defmodule SbGraphql.Schema do
  use Absinthe.Schema
  alias SbGraphql.Resolvers.{EventResolvers}

  input_object :event_filter do
    field(:sport_id, list_of(:id))
    field(:zone_id, list_of(:id))
    field(:league_id, list_of(:id))
    field(:active, :boolean)
    field(:displayed, :boolean)
    field(:live, :boolean)
  end

  query do
    field :events, list_of(:event) do
      arg(:operator_id, non_null(:id))
      arg(:filters, :event_filter)

      resolve(&EventResolvers.events/3)
    end
  end

  object :event do
    field(:id, :id)
    field(:sport_id, :id)
    # field(:live?, :boolean)
  end
end
