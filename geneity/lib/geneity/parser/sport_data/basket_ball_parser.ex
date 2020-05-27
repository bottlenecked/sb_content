defmodule Geneity.Parser.SportData.BasketBallParser do
  @basket_ball "BASK"
  alias Geneity.Parser.SportData.{IncidentParser, InplayPeriodParser}

  alias Model.LiveData.BasketBallLiveData
  alias Model.LiveData.IncidentType.BasketBallIncident

  def handle_event(:start_element, {"Inplay", attributes}, %{sport_id: @basket_ball} = state) do
    live_data = InplayPeriodParser.parse_inplay_info(%BasketBallLiveData{}, attributes)

    state = %{state | live_data: live_data}
    {:ok, state}
  end

  def handle_event(:start_element, {"Incident", attributes}, %{sport_id: @basket_ball} = state) do
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

  def handle_event(
        :end_element,
        "Ev",
        %{sport_id: @basket_ball, live_data: %BasketBallLiveData{}} = state
      ) do
    %{
      live_data:
        %{
          # incidents are now ordered first to last
          incidents: incidents
        } = live_data,
      teams: [home_team, _]
    } = state

    live_data = BasketBallLiveData.update_live_data(incidents, live_data, home_team.id)
    live_data = %{live_data | incidents: Enum.reverse(incidents)}
    state = %{state | live_data: live_data}
    {:ok, state}
  end

  def handle_event(_, _, state), do: {:ok, state}

  defp map_incident_type(geneity_type) do
    case geneity_type do
      "SCO1" ->
        BasketBallIncident.one_point()

      "SCO2" ->
        BasketBallIncident.two_point()

      "SCO3" ->
        BasketBallIncident.three_point()

      "FOUL" ->
        BasketBallIncident.foul()

      other ->
        IncidentParser.map_common_incident_type(other)
    end
  end
end
