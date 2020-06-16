defmodule SbGraphql.Schema do
  use Absinthe.Schema

  def middleware(middleware, _field, _object) do
    middleware

    # |> apply(:debug, field, object)
  end

  def apply(middleware, :debug, _field, _object) do
    if Mix.env() in [:dev, :test] do
      [{SbGraphql.Schema.Middleware.Debug, :start}] ++ middleware
    else
      middleware
    end
  end

  def apply(middleware, _, _, _), do: middleware

  import_types(Absinthe.Type.Custom)
  import_types(__MODULE__.EventTypes)
  import_types(__MODULE__.MarketTypes)
  import_types(__MODULE__.LiveDataTypes)
  import_types(__MODULE__.EventSubscriptionTypes)

  query do
    import_fields(:event_queries)
  end

  subscription do
    import_fields(:event_subscriptions)
  end
end
