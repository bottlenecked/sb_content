defmodule SbGraphql.Schema.EventTypes do
  use Absinthe.Schema.Notation
  alias SbGraphql.Resolvers.EventResolvers

  input_object :event_filter do
    field(:event_id, list_of(:id))
    field(:sport_id, list_of(:id))
    field(:zone_id, list_of(:id))
    field(:league_id, list_of(:id))
    field(:active, :boolean)
    field(:displayed, :boolean)
    field(:live, :boolean)
  end

  object :event do
    field(:id, :id)
    field(:sport_id, :id)
    field(:zone_id, :id)
    field(:league_id, :id)
    field(:live, :boolean, default_value: false)
    field(:displayed, :boolean, default_value: false)
    field(:active, :boolean, default_value: false)
    field(:live_data, :live_data)
    field(:markets, list_of(:market))
  end

  object :event_queries do
    field :events, list_of(:event) do
      arg(:operator_id, non_null(:id), default_value: "stoiximan_gr")
      arg(:filters, :event_filter)

      resolve(&EventResolvers.events/3)
    end
  end
end
