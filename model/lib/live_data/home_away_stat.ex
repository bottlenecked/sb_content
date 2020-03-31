defmodule Model.LiveData.HomeAwayStat do
  @moduledoc """
  Represents any kind of statistic that applies to all participants of 2-team sports.
  For example in soccer we can model game score, red card count, penalty counts etc. using this model.
  Values may not always be numeric- for example in tennis a score of "A" is possible
  """

  defstruct home: 0,
            away: 0
end
