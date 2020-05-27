defmodule SbGraphql.Schema.MarketTypes do
  use Absinthe.Schema.Notation

  object :market do
    field(:id, :id)
    field(:type_id, :id)
    field(:active, :boolean, default_value: false)
    field(:displayed, :boolean, default_value: false)
    field(:modifier, :string)
    field(:selections, list_of(:selection))
  end

  object :selection do
    field(:id, :id)
    field(:type_id, :id)
    field(:active, :boolean, default_value: false)
    field(:displayed, :boolean, default_value: false)
    field(:modifier, :string)
    field(:price_decimal, :float)
  end
end
