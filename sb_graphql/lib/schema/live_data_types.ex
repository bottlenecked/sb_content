defmodule SbGraphql.Schema.LiveDataTypes do
  use Absinthe.Schema.Notation

  alias Model.LiveData.{SoccerLiveData, BasketBallLiveData}

  import_types(Absinthe.Type.Custom)
  import_types(__MODULE__.ScoreTypes)
  import_types(__MODULE__.SoccerTypes)
  import_types(__MODULE__.BasketBallTypes)

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
