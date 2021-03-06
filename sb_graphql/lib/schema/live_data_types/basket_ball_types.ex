defmodule SbGraphql.Schema.LiveDataTypes.BasketBallTypes do
  use Absinthe.Schema.Notation

  import SbGraphql.Resolvers.IdentifierResolvers, only: [resolve_to_property: 1]

  @desc "Details about current state of a live basket ball match"
  object :basket_ball_live_data do
    @desc "Current period: half, quarter (depending on league) or overtime. Eg. during regular periods for a match with quarters the value will be 1 - 4, 5 or more during overtime"
    field(:current_period, :integer)

    @desc "Seconds remaining in the current period"
    field(:remaining_seconds_in_period, :integer)

    @desc "Time in UTC live data were sent from the backend. Can be used to adjust for clock differences"
    field(:correct_at, :datetime)

    @desc "Length of regular period (regular time halfs or quarters), in seconds"
    field(:regular_period_length, :integer)

    @desc "Length of overtime periods in seconds"
    field(:extra_period_length, :integer)

    @desc "True if clock not stopped by referee and period still in progress"
    field(:time_ticking, :boolean) do
      resolve(resolve_to_property(:time_ticking?))
    end

    @desc "Total points scored including regular and overtime periods"
    field(:score, :score)

    @desc "Score breakdown per period. Score is tracked separately for each period (ie score of next period does not include accumulated points over pervious periods"
    field(:period_scores, list_of(:score))
  end
end
