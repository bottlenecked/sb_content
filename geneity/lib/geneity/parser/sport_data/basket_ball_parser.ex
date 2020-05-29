defmodule Geneity.Parser.SportData.BasketBallParser do
  @basket_ball "BASK"
  alias Geneity.Parser.SportData.IncidentParser

  alias Model.LiveData.BasketBallLiveData
  alias Model.LiveData.IncidentType.BasketBallIncident

  def handle_event(:start_element, {"Inplay", attributes}, %{sport_id: @basket_ball} = state) do
    live_data =
      attributes
      |> Enum.reduce(%BasketBallLiveData{}, fn
        {"period_length", value}, acc ->
          %{acc | regular_period_length: String.to_integer(value)}

        {"num_periods", value}, acc ->
          %{acc | regular_periods_count: String.to_integer(value)}

        {"num_extra_periods", value}, acc ->
          %{acc | max_extra_periods_count: String.to_integer(value)}

        {"extra_period_length", value}, acc ->
          %{acc | extra_period_length: String.to_integer(value)}

        {"inplay_secs", value}, acc ->
          # we're sort of cheating here, but we need this value to calculate
          # remaining time in period
          Map.put(acc, :total_ellapsed_seconds, String.to_integer(value))

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

    live_data = BasketBallLiveData.update_live_data(live_data, incidents, home_team.id)
    live_data = %{live_data | incidents: Enum.reverse(incidents)}

    total_seconds = live_data.total_ellapsed_seconds
    live_data = Map.delete(live_data, :total_ellapsed_seconds)

    remaining_seconds =
      BasketBallLiveData.calculate_remaining_seconds_in_period(live_data, total_seconds)

    live_data = %{live_data | remaining_seconds_in_period: remaining_seconds}

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
