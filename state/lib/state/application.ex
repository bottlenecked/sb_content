defmodule State.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      Supervisor.child_spec({Registry, keys: :unique, name: EventServerRegistry},
        id: EventServerRegistry
      ),
      Supervisor.child_spec(
        {Registry,
         keys: :duplicate, partitions: System.schedulers_online(), name: State.PubSub.name()},
        id: State.PubSub.name()
      ),
      State.EventSupervisor,
      State.ContentListenerWorker,
      State.Telemetry
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: State.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
