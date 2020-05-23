defmodule SbApi.EventsTest do
  use SbApiWeb.ConnCase, async: true
  import TestHelper

  test "Return all event ids", %{conn: conn} do
    query = """
    query{
      events(operatorId: "stoiximan_gr"){
        id
      }
    }
    """

    response =
      conn
      |> get("/api", query: query)
      |> json_response(200)
      |> assert_no_errors()

    events = response["data"]["events"]

    # count should be equal to sb_content/geneity/test/xml/events/*.xml file count
    assert length(events) == 13
  end

  test "Filtering by event_id works", %{conn: conn} do
    query = """
    query($operatorId: ID!, $filters: EventFilter){
      events(operatorId: $operatorId, filters: $filters){
        id
      }
    }
    """

    variables =
      %{
        operatorId: "stoiximan_gr",
        filters: %{
          eventId: [5_145_382, 5_148_618]
        }
      }
      |> Jason.encode!()

    response =
      conn
      |> get("/api", query: query, variables: variables)
      |> json_response(200)
      |> assert_no_errors()

    assert %{
             "data" => %{
               "events" => [
                 %{"id" => "5145382"},
                 %{"id" => "5148618"}
               ]
             }
           } == response
  end
end
