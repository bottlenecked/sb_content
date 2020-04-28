defmodule Utils.JitterTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  property "between(min, max) always produces a number between min and max" do
    check all(
            min <- integer(-1_000_000..1_000_000),
            max <- integer((min + 1)..1_000_000),
            min < max,
            max_runs: 100_000
          ) do
      result = Utils.Jitter.between(min, max)
      assert min <= result
      assert result < max
    end
  end

  test "jitter/2 works as expected" do
    result = Utils.Jitter.jitter(1000, 100)
    assert 900 <= result
    assert result < 1100

    # jitter/2 raises when interval < jitter_value or if jitter_value < 0
    assert_raise FunctionClauseError, fn -> Utils.Jitter.jitter(100, 200) end
    assert_raise FunctionClauseError, fn -> Utils.Jitter.jitter(10, -30) end
  end
end
