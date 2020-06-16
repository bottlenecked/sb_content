defmodule SbGraphql.Schema.Helpers do
  @doc """
  Convert a module name to a GraphQL subscription field

  Example:

  iex> #{__MODULE__}.convert_change_to_subscription(%DiffEngine.Change.EventDiscovered{})
  :event_discovered
  """
  def convert_change_to_subscription(%change{}) do
    change
    |> to_string()
    |> String.split(".")
    |> List.last()
    |> Macro.underscore()
    |> String.to_atom()
  end

  def get_modules_in_directory(glob_dir) do
    glob_dir
    |> Path.join("*.ex")
    |> Path.wildcard()
    |> Enum.map(&Path.expand/1)
    |> Enum.map(&File.read!/1)
    |> Enum.map(&get_module_name/1)
    |> Enum.filter(fn name -> name != nil end)
    |> Enum.map(fn name -> "Elixir." <> name end)
    |> Enum.map(&String.to_atom/1)
  end

  defp get_module_name(file_contents) do
    ~r/defmodule (?<module_name>[^\s]+) do/
    |> Regex.named_captures(file_contents)
    |> Map.get("module_name")
  end
end
