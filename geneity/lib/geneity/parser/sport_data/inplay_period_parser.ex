defmodule Geneity.Parser.SportData.InplayPeriodParser do
  alias Model.LiveData.{SoccerLiveData, BasketBallLiveData}

  @spec parse_inplay_info(live_data :: struct(), [{name :: String.t(), value :: String.t()}]) ::
          struct()
  def parse_inplay_info(%live_data{} = data, xml_attributes)
      when live_data in [SoccerLiveData, BasketBallLiveData] do
    xml_attributes
    |> Enum.reduce(data, fn
      {"period_length", value}, acc ->
        %{acc | regular_period_length: String.to_integer(value)}

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
  end
end
