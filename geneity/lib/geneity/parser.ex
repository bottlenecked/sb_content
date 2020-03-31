defmodule Geneity.Parser do
  @behaviour Saxy.Handler
  alias Model.Event

  alias Geneity.Parser.{EventParser, MarketParser, SelectionParser, TeamParser}
  alias Geneity.Parser.SportData.{SoccerParser}

  @spec parse_event_xml(String.t()) :: Event.t()
  def parse_event_xml(xml_content) do
    {:ok, xml} = Saxy.parse_string(xml_content, Geneity.Parser, %Event{})
    xml
  end

  @impl true
  def handle_event(type, data, state) do
    {:ok, state} = EventParser.handle_event(type, data, state)
    {:ok, state} = TeamParser.handle_event(type, data, state)
    {:ok, state} = MarketParser.handle_event(type, data, state)
    {:ok, state} = SelectionParser.handle_event(type, data, state)
    {:ok, state} = SoccerParser.handle_event(type, data, state)
    {:ok, state}
  end
end
