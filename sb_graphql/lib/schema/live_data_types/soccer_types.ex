defmodule SbGraphql.Schema.LiveDataTypes.SoccerTypes do
  use Absinthe.Schema.Notation

  @desc "details about current state of a live soccer match"
  object :soccer_live_data do
    @desc "current half or overtime. Eg. during regular period will be 1 or 2, 3 or more during overtime"
    field(:current_period, :integer)

    @desc "total seconds ellapsed across all halfs (and overtime) so far. If in next period, extra time for previous period not included"
    field(:total_ellapsed_seconds, :integer)

    @desc "time in UTC live data were sent from the backend. can be used to adjust for clock differences"
    field(:correct_at, :datetime)

    @desc "length of regular period (regular time halfs), in seconds"
    field(:regular_period_length, :integer)

    @desc "length of overtime periods in seconds"
    field(:extra_period_length, :integer)

    @desc "True if clock not stopped by referee and period still in progress"

    field(:time_ticking, :boolean)

    @desc "total goals scored including regular, overtime and penalty shoot-out periods"
    field(:score, :score)

    @desc "total red cards for both teams"
    field(:red_cards, :score)

    @desc "total yellow cards for both teams"
    field(:yellow_cards, :score)

    @desc "total corners for both teams"
    field(:corners, :score)
  end
end
