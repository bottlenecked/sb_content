defmodule Geneity.Api.SimulationApi do
  @behaviour Geneity.Api.Behaviour

  def get_event_data(event_id, _operator_id, _language) do
    load_test_events()
    |> Enum.find(fn evt -> evt.id == event_id end)
    |> case do
      nil -> {:error, :event_not_found}
      evt -> {:ok, evt}
    end
  end

  def get_sport_ids(_operator_id), do: {:ok, []}

  def get_league_ids_for_sport(_sport_id, _operator_id), do: {:ok, []}

  def get_event_ids_for_league(_league_id, _operator_id), do: {:ok, []}

  def get_live_event_ids(_operator_id) do
    ids =
      load_test_events()
      |> Enum.map(fn evt -> evt.id end)

    {:ok, ids}
  end

  defp load_test_events() do
    "../../../test/xml/events/*.xml"
    |> Path.expand(__DIR__)
    |> Path.wildcard()
    |> Enum.map(&File.read!/1)
    |> Enum.map(&Geneity.Parser.parse_event_xml!/1)
  end
end
