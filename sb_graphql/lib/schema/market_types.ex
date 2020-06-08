defmodule SbGraphql.Schema.MarketTypes do
  use Absinthe.Schema.Notation

  import SbGraphql.Resolvers.IdentifierResolvers, only: [resolve_to_property: 1]

  @desc "a market groups a set of possible results (selections) for betting purposes"
  object :market do
    @desc "unique identifier"
    field(:id, :id)

    @desc "type of market (like Match Result, Over/Under etc.)"
    field(:type_id, :id)

    @desc "flag indicating whether betting is available on this market. If inactive neither betting nor cashout (for bets already placed in this market) are available"
    field(:active, :boolean, default_value: false) do
      resolve(resolve_to_property(:active?))
    end

    @desc "flag indicating whether the market and its selections should be visible to clients. If not visible betting is not currently allowed for this market"
    field(:displayed, :boolean, default_value: false) do
      resolve(resolve_to_property(:displayed?))
    end

    @desc "meta info about the market. For example many markets of the over/under type maybe available, each with a different modifier like 2.5, 3.5 etc."
    field(:modifier, :string)

    @desc "if set, indicates point up until betting on this market will be available"
    field(:close_time, :datetime)

    @desc "list of this market's selections"
    field(:selections, list_of(:selection))
  end

  @desc "Models a possible outcome (like win/lose/draw) with odds signifying probability of that outcome"
  object :selection do
    @desc "unique selection id"
    field(:id, :id)

    @desc "meta data about the selection. Example: for a 3 way market like match result values like 'H','A' and 'D' indicate the outcome this selection refers to"
    field(:type_id, :id)

    @desc "flag indicating betting status for this selection. Inactive selections cannot be bet on and bets on this selection cannot be cashed out while the selection remains inactive"
    field(:active, :boolean, default_value: false) do
      resolve(resolve_to_property(:active?))
    end

    @desc "flag indicating visibility status for clients for this selection. Undisplayed selections cannot be bet on"
    field(:displayed, :boolean, default_value: false) do
      resolve(resolve_to_property(:displayed?))
    end

    @desc "extra data about this selection. Example: in handicap markets, one selection might have a -3.5 modifier and the other +3.5"
    field(:modifier, :string)

    @desc "odds this market is traded at in decimal format, e.g. '1.20'. Odds are (1/probability - operator_margin)"
    field(:price_decimal, :float)
  end
end
