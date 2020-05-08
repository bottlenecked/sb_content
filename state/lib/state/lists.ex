defmodule State.Lists do
  @moduledoc """
  Find event ids by common characteristics
  """

  def get_all_event_ids(operator_id) when not is_nil(operator_id) do
    Registry.select(State.EventWorker.registry_name(), [
      {{{:event, :"$1", operator_id}, :_, :_}, [], [:"$1"]}
    ])
  end

  def get_event_ids_by_sport_id(operator_id, sport_id) do
  end
end
