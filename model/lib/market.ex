defmodule Model.Market do
  defstruct [
    :id,
    :type_id,
    :active?,
    :modifier,
    displayed?: true,
    selections: []
  ]
end
