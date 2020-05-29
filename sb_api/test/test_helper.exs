ExUnit.start(colors: [enabled: true])

defmodule TestHelper do
  use SbApiWeb.ConnCase

  def assert_no_errors(json_response) do
    assert json_response["errors"] == nil

    json_response
  end

  def get_response(conn, query, variables) do
    conn
    |> get("/api", query: query, variables: Jason.encode!(variables))
    |> json_response(200)
    |> assert_no_errors()
  end
end
