defmodule SbGraphql.Schema.Helpers.Macros do
  defmacro import_types_under(glob_dir) do
    modules = SbGraphql.Schema.Helpers.get_modules_in_directory(glob_dir)

    for module <- modules do
      quote do
        import_types(unquote(module))
      end
    end
  end
end
