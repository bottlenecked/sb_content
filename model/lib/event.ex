defmodule Model.Event do
  # @type t() :: %__MODULE__{
  #         sport_id: String.t()
  #       }
  # use ExtrapolateStruct

  defstruct [
    :id,
    :sport_id,
    :zone_id,
    :league_id,
    :event_id,
    :active,
    :start_time,
    :live,
    :display_order,
    displayed: true,
    markets: []
  ]
end
