ExUnit.start(colors: [enabled: true])

Geneity.Api.set_api_mode(:test)
Geneity.ContentDiscovery.ScrapeSupervisor.start_scraper("stoiximan_gr", :live)

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
