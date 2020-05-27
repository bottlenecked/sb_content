defmodule Geneity.Parser.SportData.IncidentParser do
  alias Model.LiveData.Incident
  alias Model.LiveData.IncidentType.CommonIncident

  @spec parse_incident(
          [{name :: String.t(), value :: String.t()}],
          map_incident_type :: (String.t() -> atom())
        ) ::
          Incident.t()
  def parse_incident(xml_attributes, map_incident_type) do
    xml_attributes
    |> Enum.reduce(%Incident{}, fn
      {"incident_id", value}, acc ->
        %{acc | id: String.to_integer(value)}

      {"type", value}, acc ->
        type = map_incident_type.(value)
        %{acc | type: type}

      {"team_id", value}, acc ->
        %{acc | team_id: String.to_integer(value)}

      {"inplay_period_mins", value}, acc ->
        %{acc | game_time: String.to_integer(value)}

      {"time", value}, acc ->
        {:ok, value, 0} = DateTime.from_iso8601(value <> "Z")
        %{acc | timestamp: value}

      {"comment", value}, acc ->
        %{acc | extra: value}

      _, acc ->
        acc
    end)
  end

  @spec map_common_incident_type(String.t()) :: atom()
  def map_common_incident_type(type)
  def map_common_incident_type("EBEG"), do: CommonIncident.event_start()
  def map_common_incident_type("EEND"), do: CommonIncident.event_end()
  def map_common_incident_type("PBEG"), do: CommonIncident.period_start()
  def map_common_incident_type("PEND"), do: CommonIncident.period_end()
  def map_common_incident_type("CMNT"), do: CommonIncident.comment()
  def map_common_incident_type(_), do: :ignore
end
