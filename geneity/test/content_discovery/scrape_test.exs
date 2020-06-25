defmodule Geneity.ContentDiscovery.ScrapeTest do
  use ExUnit.Case

  test "starting and stopping content discovery" do
    alias Geneity.ContentDiscovery.ScrapeSupervisor

    Geneity.Api.set_api_mode(:test)
    Geneity.PubSub.subscribe_new_events()

    # no message after subscribing because content discovery is not yet started
    assert length(ScrapeSupervisor.scrapers_list()) == 0
    refute_receive(_any)

    ScrapeSupervisor.start_scraper("stoiximan_gr", :live)
    assert length(ScrapeSupervisor.scrapers_list()) == 1
    assert_receive({:new_events, {"stoiximan_gr", list}}, 1000)

    ScrapeSupervisor.stop_scrapper("stoiximan_gr", :live)
    assert length(ScrapeSupervisor.scrapers_list()) == 0
  end
end
