defmodule DiffEngine.Result do
  defmacro alias_result_structs() do
    quote do
      alias DiffEngine.Result.NoDiff

      alias DiffEngine.Result.Event.{
        StartTimeChanged,
        StatusChanged,
        LiveStatusChanged,
        DisplayOrderChanged,
        VisibilityChanged
      }
    end
  end
end
