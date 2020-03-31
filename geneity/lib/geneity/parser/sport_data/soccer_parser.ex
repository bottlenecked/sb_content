defmodule Geneity.Parser.SportData.SoccerParser do
  @soccer "FOOT"
  alias Model.LiveData.{SoccerLiveData, Incident}
  alias Model.LiveData.SoccerLiveData.IncidentType

  alias Geneity.Parser.TeamParser

  def handle_event(:start_element, {"Inplay", attributes}, %{sport_id: @soccer} = state) do
    live_data =
      attributes
      |> Enum.reduce(%SoccerLiveData{}, fn
        {"period_length", value}, acc ->
          %{acc | regular_period_length: String.to_integer(value)}

        {"extra_period_length", value}, acc ->
          %{acc | extra_period_length: String.to_integer(value)}

        {"inplay_secs", value}, acc ->
          %{acc | period_ellapsed_seconds: String.to_integer(value)}

        {"correct_at", value}, acc ->
          {:ok, value, 0} = DateTime.from_iso8601(value <> "Z")
          %{acc | correct_at: value}

        {"clock_status", value}, acc ->
          %{acc | time_ticking?: value == "TICKING"}

        _, acc ->
          acc
      end)

    state = %{state | live_data: live_data}
    {:ok, state}
  end

  def handle_event(:start_element, {"Incident", attributes}, %{sport_id: @soccer} = state) do
    %{live_data: live_data} = state
    %{incidents: incidents} = live_data

    incident =
      attributes
      |> Enum.reduce(%Incident{}, fn
        {"incident_id", value}, acc ->
          %{acc | id: String.to_integer(value)}

        {"type", value}, acc ->
          type = map_incident_type(value)
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

    if incident.type == :ignore do
      {:ok, state}
    else
      incidents = [incident | incidents]
      live_data = %{live_data | incidents: incidents}
      state = %{state | live_data: live_data}
      {:ok, state}
    end
  end

  def handle_event(:end_element, "Ev", %{sport_id: @soccer} = state) do
    # when we are done with parsing individual incidents, we need to
    # enumerate over them and update live data counters (scores, red cards etc.)
    {:ok, state}
  end

  def handle_event(_, _, state), do: {:ok, state}

  defp map_incident_type(geneity_type) do
    case geneity_type do
      "GOAL" ->
        IncidentType.goal()

      _ ->
        :ignore
    end
  end
end
