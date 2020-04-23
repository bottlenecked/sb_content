defmodule Geneity.Api do
  alias Freshness.Response
  alias Geneity.Parser
  alias Model.Event
  alias Geneity.Api.Operators

  @spec get_event_data(pos_integer(), String.t(), String.t()) ::
          {:ok, Event.t()} | {:error, any()}
  def get_event_data(event_id, operator_id \\ Operators.stoiximan_gr(), language \\ "en") do
    path =
      "/content_api?key=get_inplay_event_detail&lang=#{language}&ev_id=#{event_id}&pocasite=#{
        operator_id
      }"

    headers = [
      {"Connection", "Keep-Alive"},
      {"X-Geneity-Site", operator_id}
    ]

    case Freshness.get(:geneity, path, headers) do
      {:ok, response} -> process_event_response(response)
      {:error, _} = error -> error
    end
  end

  defp process_event_response(%Response{status: 200, data: data}) do
    # even when geneity replies with 200 OK the event might still be unavailable
    case Parser.parse_event_xml(data) do
      {:ok, event} ->
        if(is_nil(event.id)) do
          {:error, :event_not_found}
        else
          {:ok, event}
        end

      {:error, _xml_error} = error ->
        error
    end
  end

  defp process_event_response(%Response{status: status}) do
    {:error, status}
  end
end
