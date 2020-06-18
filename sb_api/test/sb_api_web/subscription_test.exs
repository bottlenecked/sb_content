defmodule SbApiWeb.Test.SubscriptionTest do
  use SbApiWeb.SubscriptionCase

  test "blah", %{socket: socket} do
    subscription = """
    subscription {
      changes {
        ...on StatusChanged {
          eventId,
          active
        },
        __typename
      }
    }
    """

    # setup a subscription
    ref = push_doc(socket, subscription)

    assert_reply(ref, :ok, %{subscriptionId: subscription_id})

    # trigger a dummy event
    change = %DiffEngine.Change.Event.StatusChanged{event_id: 1, active?: true}
    State.PubSub.publish_changes("stoiximan_gr", [change])

    # check to see if we got subscription data
    expected = %{
      result: %{
        data: %{
          "changes" => [%{"__typename" => "StatusChanged", "active" => true, "eventId" => "1"}]
        }
      },
      subscriptionId: subscription_id
    }

    assert_push("subscription:data", push)
    assert expected == push
  end
end
