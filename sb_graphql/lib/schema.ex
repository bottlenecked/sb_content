defmodule SbGraphql.Schema do
  use Absinthe.Schema

  def middleware(middleware, %{identifier: identifier} = field, object)
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

  def middleware(middleware, _, _), do: middleware

  import_types(__MODULE__.EventTypes)

  query do
    import_fields(:event_queries)
  end
end
