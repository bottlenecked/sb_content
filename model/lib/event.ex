defmodule Model.Event do
  @type t() :: %__MODULE__{}

  defstruct [
    :id,
    :sport_id,
    :zone_id,
    :league_id,
    :br_match_id,
    :active?,
    :start_time,
    :live?,
    :display_order,
    :live_data,
    displayed?: true,
    teams: [],
    markets: []
  ]
end
