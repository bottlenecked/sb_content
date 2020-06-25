defmodule SbApiWeb.Test.EventSubscriptionTest do
  use SbApiWeb.SubscriptionCase

  test "status changed is captured", %{socket: socket} do
    subscription = """
    subscription{
      changes{
        ...on StatusChanged{
          eventId,
          active
        },
        __typename
      }
    }
    """

    # setting up the subscription
    ref = push_doc(socket, subscription)

    assert_reply(ref, :ok, %{subscriptionId: subscription_id})

    # trigger a dummy event
    change = %DiffEngine.Change.Event.StatusChanged{event_id: 1, active?: true}
    State.PubSub.publish_changes("stoiximan_gr", [change])

    # assert that the change is received

    expected = %{
      result: %{
        data: %{
          "changes" => [%{"__typename" => "StatusChanged", "active" => true, "eventId" => "1"}]
        }
      },
      subscriptionId: subscription_id
    }

    assert_push("subscription:data", actual)

    assert actual == expected
  end
end
