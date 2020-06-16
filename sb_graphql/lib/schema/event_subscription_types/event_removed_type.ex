defmodule SbGraphql.Schema.EventSubscriptionTypes.EventRemovedType do
  use Absinthe.Schema.Notation

  @desc "signals that an event is no longer available to customers for viewing, betting or other purposes"
  object :event_removed do
    field(:event_id, :id)
  end
end
