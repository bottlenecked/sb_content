defmodule Geneity.Parser.SportData.SoccerParser do
  @soccer "FOOT"
  alias Geneity.Parser.SportData.IncidentParser

  alias Model.LiveData.SoccerLiveData
  alias Model.LiveData.IncidentType.SoccerIncident

  def handle_event(:start_element, {"Inplay", attributes}, %{sport_id: @soccer} = state) do
    live_data =
      attributes
      |> Enum.reduce(%SoccerLiveData{}, fn
        {"period_length", value}, acc ->
          %{acc | regular_period_length: String.to_integer(value)}

        {"num_periods", value}, acc ->
          %{acc | regular_periods_count: String.to_integer(value)}

        {"num_extra_periods", value}, acc ->
          %{acc | max_extra_periods_count: String.to_integer(value)}

        {"extra_period_length", value}, acc ->
          %{acc | extra_period_length: String.to_integer(value)}

        {"inplay_secs", value}, acc ->
          %{acc | total_ellapsed_seconds: String.to_integer(value)}

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

    incident = IncidentParser.parse_incident(attributes, &map_incident_type/1)

    if incident.type == :ignore do
      {:ok, state}
    else
      incidents = [incident | incidents]
      live_data = %{live_data | incidents: incidents}
      state = %{state | live_data: live_data}
      {:ok, state}
    end
  end

  def handle_event(:end_element, "Ev", %{sport_id: @soccer, live_data: %SoccerLiveData{}} = state) do
    # when we are done with parsing individual incidents, we need to
    # enumerate over them and update live data counters (scores, red cards etc.)
    # but it is only safe to do it at the end of Ev element, because Teams follow incidents
    # in the XML structure and and we need the home team id to do it
    %{
      live_data:
        %{
          # incidents are now ordered first to last
          incidents: incidents
        } = live_data,
      teams: [home_team, _]
    } = state

    live_data = SoccerLiveData.update_live_data(live_data, incidents, home_team.id)
    live_data = %{live_data | incidents: Enum.reverse(incidents)}
    state = %{state | live_data: live_data}
    {:ok, state}
  end

  def handle_event(_, _, state), do: {:ok, state}

  defp map_incident_type(geneity_type) do
    case geneity_type do
      "GOAL" ->
        SoccerIncident.goal()

      "CRNR" ->
        SoccerIncident.corner()

      "RED" ->
        SoccerIncident.red_card()

      "YELL" ->
        SoccerIncident.yellow_card()

      "FKIC" ->
        SoccerIncident.free_kick()

      "THRO" ->
        SoccerIncident.throw_in()

      "GKIC" ->
        SoccerIncident.goal_kick()

      other ->
        IncidentParser.map_common_incident_type(other)
    end
  end
end
