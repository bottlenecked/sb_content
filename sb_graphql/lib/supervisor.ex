defmodule SbGraphql.Supervisor do
  use Supervisor

  def start_link(_) do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    [
      SbGraphql.ChangeListener
    ]
    |> Supervisor.init(strategy: :one_for_one)
  end
end
