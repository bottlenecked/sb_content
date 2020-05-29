defmodule SbApi.LiveDataQuery.BasketBallQueryTest do
  use SbApiWeb.ConnCase, async: true
  import TestHelper

  test "return basketball live data", %{conn: conn} do
    query = """
      query($filters: EventFilter){
        events(operatorId: "stoiximan_gr", filters: $filters){
          liveData{
            ...on BasketBallLiveData{
              score{
                ...scoreFields
              },
              currentPeriod,
              remainingSecondsInPeriod,
              correctAt,
              regularPeriodLength,
              extraPeriodLength,
              timeTicking,
              periodScores{
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
        eventId: 5_148_618
      }
    }

    response = get_response(conn, query, variables)

    assert %{
             "data" => %{
               "events" => [
                 %{
                   "liveData" => %{
                     "correctAt" => "2020-03-30T11:59:40Z",
                     "currentPeriod" => 2,
                     "extraPeriodLength" => 300,
                     "regularPeriodLength" => 600,
                     "remainingSecondsInPeriod" => 4,
                     "timeTicking" => true,
                     "score" => %{"away" => 51, "home" => 35},
                     "periodScores" => [
                       %{"away" => 30, "home" => 18},
                       %{"away" => 21, "home" => 17}
                     ]
                   }
                 }
               ]
             }
           } = response
  end
end
