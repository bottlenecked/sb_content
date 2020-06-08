defmodule Geneity.Parser.LeagueParser do
  @behaviour Saxy.Handler

  @spec get_event_ids(String.t() | iolist()) :: Event.t()
  def get_event_ids(xml_content)

  def get_event_ids(xml_content) when is_binary(xml_content) do
    Saxy.parse_string(xml_content, __MODULE__, [])
  end

  def get_event_ids(xml_content) do
    Saxy.parse_stream(xml_content, __MODULE__, [])
  end

  def get_event_ids!(xml_content) do
    case get_event_ids(xml_content) do
      {:ok, event} -> event
      {:error, reason} -> raise reason
    end
  end

  def handle_event(:start_element, {"Ev", attrs}, list) do
    code =
      attrs
      |> Enum.filter(fn {k, _v} -> k == "ev_id" end)
      |> Enum.map(fn {_k, v} -> v end)
      |> List.first()

    {:ok, [code | list]}
  end

  def handle_event(:end_element, "ContentAPI", state), do: {:ok, Enum.reverse(state)}

  def handle_event(_, _, state), do: {:ok, state}
end
