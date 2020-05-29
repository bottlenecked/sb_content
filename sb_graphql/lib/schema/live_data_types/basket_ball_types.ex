defmodule SbGraphql.Schema.LiveDataTypes.BasketBallTypes do
  use Absinthe.Schema.Notation

  @desc "Details about current state of a live basket ball match"
  object :basket_ball_live_data do
    @desc "Current half, quarter (depending on league) or overtime. Eg. during regular period will be 1 - 4, 5 or more during overtime"
    field(:current_period, :integer)

    @desc "Total seconds ellapsed across all halfs/periods (and overtime) so far"
    field(:total_ellapsed_seconds, :integer)

    @desc "Time in utc data were sent from the backend. Can be used to adjust for clock skew"
    field(:correct_at, :datetime)

    @desc "Length of regular period (regular time halfs or quarters), in seconds"
    field(:regular_period_length, :integer)

    @desc "Length of overtime periods in seconds"
    field(:extra_period_length, :integer)

    @desc "True if clock not stopped by referee or period ended"
    field(:time_ticking, :boolean)

    @desc "Total points scored including regular and overtime periods"
    field(:score, :score)

    @desc "Score breakdown per period. Score is tracked separately for each period (ie score of next period does not include accumulated points over pervious periods"
    field(:period_scores, list_of(:score))
  end
end
