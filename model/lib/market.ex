defmodule Model.Market do
  defstruct [
    :id,
    :type_id,
    :active?,
    :modifier,
    :order,
    displayed?: true,
    selections: []
  ]
end
