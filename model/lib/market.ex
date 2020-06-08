defmodule Model.Market do
  defstruct [
    :id,
    :type_id,
    :active?,
    :modifier,
    :order,
    :close_time,
    displayed?: true,
    selections: []
  ]
end
