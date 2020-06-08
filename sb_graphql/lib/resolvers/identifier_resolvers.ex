defmodule SbGraphql.Resolvers.IdentifierResolvers do
  def resolve_to_property(name) do
    fn parent, _arg, _res ->
      {:ok, Map.get(parent, name)}
    end
  end
end
