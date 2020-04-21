defmodule State.Content do
  @moduledoc """
  A facade module delegating calls to the provider apis. In case we need to
  change the provider the changes should hopefully be limited to this file only
  """

  def get_event_data(event_id, operator_id), do: Geneity.Api.get_event_data(event_id, operator_id)
end
