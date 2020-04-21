defmodule Geneity.Api.Operators do
  @operators [
    :betano_at,
    :betano_bg,
    :betano_br,
    :betano_de,
    :betano_pl,
    :betano_pt,
    :betano_ro,
    :stoiximan_gr
  ]

  for operator <- @operators do
    def unquote(operator)(), do: to_string(unquote(operator))
  end
end
