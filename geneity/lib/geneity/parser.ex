defmodule Geneity.Parser do
  @behaviour Saxy.Handler

  alias Model.Event

  alias Geneity.Parser.{EventParser, MarketParser, SelectionParser, TeamParser}
  alias Geneity.Parser.SportData.{SoccerParser, BasketBallParser}

  @spec parse_event_xml(String.t() | iolist()) :: Event.t()
  def parse_event_xml(xml_content)

  def parse_event_xml(xml_content) when is_binary(xml_content) do
    Saxy.parse_string(xml_content, __MODULE__, %Event{})
  end

  def parse_event_xml(xml_content) do
    Saxy.parse_stream(xml_content, __MODULE__, %Event{})
  end

  def parse_event_xml!(xml_content) do
    case parse_event_xml(xml_content) do
      {:ok, event} -> event
      {:error, reason} -> raise reason
    end
  end

  @impl true
  def handle_event(type, data, state) do
    {:ok, state} = EventParser.handle_event(type, data, state)
    {:ok, state} = TeamParser.handle_event(type, data, state)
    {:ok, state} = MarketParser.handle_event(type, data, state)
    {:ok, state} = SelectionParser.handle_event(type, data, state)
    {:ok, state} = SoccerParser.handle_event(type, data, state)
    {:ok, state} = BasketBallParser.handle_event(type, data, state)
    {:ok, state}
  end
end
