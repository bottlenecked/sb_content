defmodule SbGraphql.Schema.EventTypes do
  use Absinthe.Schema.Notation
  alias SbGraphql.Resolvers.EventResolvers

  @desc "filters to search events with"
  input_object :event_filter do
    @desc "filter based on event ids"
    field(:event_id, list_of(:id))

    @desc "filter based on sport ids"
    field(:sport_id, list_of(:id))

    @desc "filter based on zone ids"
    field(:zone_id, list_of(:id))

    @desc "filter based on league id"
    field(:league_id, list_of(:id))

    @desc "filter based on betting availability. No bets can be placed on inactive events and no cashout is available for bets on these events"
    field(:active, :boolean)

    @desc "filter events based on visibility. Undisplayed events cannot be bet on, but cashout is still available"
    field(:displayed, :boolean)

    @desc "filter based on live status of an event"
    field(:live, :boolean)
  end

  @desc "An event models either a match or other non-sports events (like tv shows) in the system"
  object :event do
    @desc "unique event identifier"
    field(:id, :id)

    @desc "the sport id of the event"
    field(:sport_id, :id)

    @desc "the league id of the event"
    field(:league_id, :id)

    @desc "a flag indicating whether event is currently in progress"
    field(:live, :boolean, default_value: false)

    @desc "a flag indicating whether an event is visible to clients or not. Only visible events can be bet on"
    field(:displayed, :boolean, default_value: false)

    @desc "a flag indicating whether betting is available on this event. If inactive, neither betting nor cashout is allowed for bets on this event"
    field(:active, :boolean, default_value: false)

    @desc "clock status, scoreboards and other info pertaining to an in-progress event"
    field(:live_data, :live_data)

    @desc "list of markets available for betting in this event"
    field(:markets, list_of(:market))
  end

  object :event_queries do
    @desc "return lists of events based on various criteria"
    field :events, list_of(:event) do
      @desc "id of operator to lookup events in. Event data may change between operators (like odds or market availability)"
      arg(:operator_id, non_null(:id), default_value: "stoiximan_gr")

      @desc "search criteria"
      arg(:filters, :event_filter)

      resolve(&EventResolvers.events/3)
    end
  end
end
