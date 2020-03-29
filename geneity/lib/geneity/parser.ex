defmodule Geneity.Parser do
  alias Model.Event

  @spec parse_event_xml(String.t()) :: Event.t()
  def parse_event_xml(xml_content) do
    {:ok, xml} = Saxy.parse_string(xml_content, Geneity.Parser.EventParser, %Event{})
    xml
  end
end
