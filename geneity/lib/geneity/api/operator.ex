defmodule Geneity.Api.Operator do
  @type t() :: String.t()

  @operators [
    # :betano_de,
    # :betano_pt,
    # :betano_ro,
    :stoiximan_gr
  ]

  for operator <- @operators do
    def unquote(operator)(), do: to_string(unquote(operator))
  end

  def all(), do: Enum.map(@operators, &to_string/1)
end
