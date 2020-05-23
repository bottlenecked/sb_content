ExUnit.start(colors: [enabled: true])

defmodule TestHelper do
  use ExUnit.Case

  def assert_no_errors(json_response) do
    assert json_response["errors"] == nil

    json_response
  end
end
