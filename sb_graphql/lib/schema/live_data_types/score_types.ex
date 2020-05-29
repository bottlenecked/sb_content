defmodule SbGraphql.Schema.LiveDataTypes.ScoreTypes do
  use Absinthe.Schema.Notation

  @desc "represents a home/away stat. E.g. used in soccer for score, red cards etc. and also in other sports"
  object :score do
    @desc "home team score"
    field(:home, :integer)

    @desc "away team score"
    field(:away, :integer)
  end
end
