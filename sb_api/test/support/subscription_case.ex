defmodule SbApiWeb.SubscriptionCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      use SbApiWeb.ChannelCase

      use Absinthe.Phoenix.SubscriptionTest,
        schema: SbGraphql.Schema

      setup do
        {:ok, socket} = Phoenix.ChannelTest.connect(SbApiWeb.UserSocket, %{})
        {:ok, socket} = Absinthe.Phoenix.SubscriptionTest.join_absinthe(socket)
        {:ok, socket: socket}
      end
    end
  end
end
