defmodule SbGraphql.Schema.LiveDataTypes do
  use Absinthe.Schema.Notation
  import SbGraphql.Schema.Helpers.Macros, only: [import_types_under: 1]

  alias Model.LiveData.{SoccerLiveData, BasketBallLiveData}

  import_types_under("./lib/schema/live_data_types/")

  union :live_data do
    types([
      :soccer_live_data,
      :basket_ball_live_data
    ])

    resolve_type(fn
      %SoccerLiveData{}, _ -> :soccer_live_data
      %BasketBallLiveData{}, _ -> :basket_ball_live_data
      _, _ -> nil
    end)
  end
end
