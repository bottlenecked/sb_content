defmodule SbGraphql.Schema do
  use Absinthe.Schema

  def middleware(middleware, field, object) do
    middleware
    |> apply(:handle_questionmarks, field, object)
    |> apply(:debug, field, object)
  end

  def apply(middleware, :handle_questionmarks, %{identifier: identifier} = field, object)
      when identifier in [
             :live,
             :active,
             :displayed
           ] do
    key = :"#{identifier}?"
    new_middleware = {Absinthe.Middleware.MapGet, key}

    middleware
    |> Absinthe.Schema.replace_default(new_middleware, field, object)
  end

  def apply(middleware, :debug, _field, _object) do
    if Mix.env() in [:dev, :test] do
      [{SbGraphql.Schema.Middleware.Debug, :start}] ++ middleware
    else
      middleware
    end
  end

  def apply(middleware, _, _, _), do: middleware

  import_types(__MODULE__.EventTypes)

  query do
    import_fields(:event_queries)
  end
end
