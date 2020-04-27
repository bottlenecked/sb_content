defmodule Geneity.Api.EventResponseProcessor do
  alias Freshness.Response
  alias Geneity.Parser
  alias Model.Event

  def process(result) do
    with {:response, {:ok, response}} <- {:response, result},
         {:status, %Response{status: 200} = resp} <- {:status, response},
         {:parse, {:ok, %Event{} = evt}} <- {:parse, Parser.parse_event_xml(resp.data)},
         {:exists?, %Event{id: id} = evt} when not is_nil(id) <- {:exists?, evt} do
      {:ok, evt}
    else
      {:response, {:error, _} = error} -> error
      {:status, %Response{status: status}} -> {:error, status}
      {:parse, {:error, _xml_error} = error} -> error
      {:exists?, _evt} -> {:error, :event_not_found}
    end
  end
end
