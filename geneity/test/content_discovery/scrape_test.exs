defmodule Geneity.ContentDiscovery.ScrapeTest do
  use ExUnit.Case

  test "starting and stopping content discovery" do
    alias Geneity.ContentDiscovery.ScrapeSupervisor

    Geneity.Api.set_api_mode(:test)
    events = Geneity.PubSub.subscribe_new_events()

    assert length(ScrapeSupervisor.children()) == 0
    assert length(events) == 0

    ScrapeSupervisor.start_child("stoiximan_gr", :live)
    assert length(ScrapeSupervisor.children()) == 1
    assert_receive({:new_events, {"stoiximan_gr", list}}, 1000)

    ScrapeSupervisor.stop_child("stoiximan_gr", :live)
    assert length(ScrapeSupervisor.children()) == 0
  end
end
