ExUnit.start(colors: [enabled: true])

defmodule Helpers do
  def load_xml_file(file_name) do
    File.read!("./test/xml/#{file_name}.xml")
  end
end
