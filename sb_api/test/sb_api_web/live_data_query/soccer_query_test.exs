defmodule SbApi.LiveDataQuery.SoccerDataQueryTest do
  use SbApiWeb.ConnCase, async: true
  import TestHelper

  test "return soccer live data", %{conn: conn} do
    query = """
      query($filters: EventFilter){
        events(operatorId: "stoiximan_gr", filters: $filters){
          liveData{
            ...on SoccerLiveData{
              score{
                ...scoreFields
              },
              currentPeriod,
              totalEllapsedSeconds,
              correctAt,
              regularPeriodLength,
              extraPeriodLength,
              timeTicking,
              redCards{
                ...scoreFields
              },
              yellowCards{
                ...scoreFields
              },
              corners{
                ...scoreFields
              }
            }
          }
        }
      }

      fragment scoreFields on Score {
        home,
        away
      }
    """

    variables = %{
      filters: %{
        eventId: 5_164_252
      }
    }

    response = get_response(conn, query, variables)

    assert %{
             "data" => %{
               "events" => [
                 %{
                   "liveData" => %{
                     "correctAt" => "2020-04-02T10:17:11Z",
                     "currentPeriod" => 3,
                     "regularPeriodLength" => 2700,
                     "timeTicking" => true,
                     "totalEllapsedSeconds" => 5993,
                     "extraPeriodLength" => 900,
                     "corners" => %{"home" => 4, "away" => 8},
                     "redCards" => %{"away" => 0, "home" => 0},
                     "score" => %{"away" => 1, "home" => 2},
                     "yellowCards" => %{"away" => 0, "home" => 1}
                   }
                 }
               ]
             }
           } = response
  end
end
