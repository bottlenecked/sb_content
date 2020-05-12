defmodule SbGraphql.Schema do
  use Absinthe.Schema

  import_types(__MODULE__.EventTypes)

  query do
    import_fields(:event_queries)
  end
end
