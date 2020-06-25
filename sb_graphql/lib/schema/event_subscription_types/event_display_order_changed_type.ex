defmodule SbGraphql.Schema.EventSubscriptionTypes.EventDisplayOrderChangedType do
  use Absinthe.Schema.Notation

  @desc "fired whenever an event's global order has changed"
  object :display_order_changed do
    field(:event_id, :id)

    field(:display_order, :integer)
  end
end
