defmodule GeneityTest do
  use ExUnit.Case
  doctest Geneity

  test "greets the world" do
    assert Geneity.hello() == :world
  end
end
