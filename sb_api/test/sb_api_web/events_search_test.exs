defmodule SbApi.EventsSearchTest do
  use SbApiWeb.ConnCase, async: true
  import TestHelper

  @query """
  query($filters: EventFilter){
    events(operatorId: "stoiximan_gr", filters: $filters){
      id
    }
  }
  """

  test "Return all event ids", %{conn: conn} do
    response = get_response(conn, @query, %{filters: %{}})

    events = response["data"]["events"]

    # count should be equal to sb_content/geneity/test/xml/events/*.xml file count
    assert length(events) == 13
  end

  test "optimization for single event id search works", %{conn: conn} do
    variables = %{
      filters: %{
        eventId: 5_145_382
      }
    }

    response = get_response(conn, @query, variables)

    assert %{
             "data" => %{
               "events" => [
                 %{"id" => "5145382"}
               ]
             }
           } == response
  end

  test "Filtering by event_id works", %{conn: conn} do
    variables = %{
      filters: %{
        eventId: [5_145_382, 5_148_618]
      }
    }

    response = get_response(conn, @query, variables)

    assert %{
             "data" => %{
               "events" => [
                 %{"id" => "5148618"},
                 %{"id" => "5145382"}
               ]
             }
           } == response
  end

  test "filtering by sport_id", %{conn: conn} do
    variables = %{
      filters: %{
        sportId: "ICEH"
      }
    }

    response = get_response(conn, @query, variables)

    events = response["data"]["events"]
    assert length(events) == 1
  end

  test "filtering by zone_id", %{conn: conn} do
    variables = %{
      filters: %{
        zoneId: 189_452
      }
    }

    response = get_response(conn, @query, variables)

    events = response["data"]["events"]
    assert length(events) == 1
    assert hd(events)["id"] == "5145382"
  end

  test "filtering by league_id", %{conn: conn} do
    variables = %{
      filters: %{
        leagueId: [194_426, 194_253]
      }
    }

    response = get_response(conn, @query, variables)

    ids =
      response["data"]["events"]
      |> Enum.map(fn evt -> evt["id"] end)

    assert ["5278338", "5086009"] == ids
  end

  test "searching by live status", %{conn: conn} do
    variables = %{
      filters: %{
        live: true
      }
    }

    response = get_response(conn, @query, variables)

    events = response["data"]["events"]
    assert length(events) == 11
  end

  test "searching by active status", %{conn: conn} do
    variables = %{
      filters: %{
        active: true
      }
    }

    response = get_response(conn, @query, variables)

    events = response["data"]["events"]
    assert length(events) == 11
  end

  test "searching by displayed status", %{conn: conn} do
    variables = %{
      filters: %{
        displayed: false
      }
    }

    response = get_response(conn, @query, variables)

    events = response["data"]["events"]
    assert length(events) == 0
  end
end
