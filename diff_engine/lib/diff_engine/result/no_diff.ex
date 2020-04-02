defmodule DiffEngine.Result.NoDiff do
  defstruct []

  def value(), do: %__MODULE__{}
end
