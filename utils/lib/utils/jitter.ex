defmodule Utils.Jitter do
  @doc """
  Introduce some jitter for next interval. The jitter value should be smaller than interval.
  Returns a value equal to (interval ± jitter)
  """
  @spec jitter(non_neg_integer(), non_neg_integer()) :: non_neg_integer()
  def jitter(interval, jitter_value) when interval > jitter_value and jitter_value >= 0,
    do: between(interval - jitter_value, interval + jitter_value)

  @doc """
  Returns a new integer between [min, max) (exclusive). Useful for scheduling next job
  with a small jitter to avoid DOSing a system by jobs scheduled at same intervals
  """
  @spec between(integer(), integer()) :: integer()
  def between(min, max) do
    rnd =
      (max - min)
      |> abs()
      |> :rand.uniform()

    min + rnd - 1
  end
end
