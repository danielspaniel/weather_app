require "test_helper"

class WeatherReportCacheTest < ActiveSupport::TestCase
  ZIP_06605 = "06605".freeze
  BRIDGEPORT_CT = "Bridgeport CT".freeze
  WEATHER_RESPONSE = "06605: ☀️   +22°C\n".freeze

  teardown do
    Rails.cache.clear
    travel_back
  end

  test "caches successful response" do
    stub = stub_request(:get, "#{WeatherReport::SEARCH_URL}/#{ZIP_06605}")
           .with(query: WeatherReport::SEARCH_PARAMS)
           .to_return(body: WEATHER_RESPONSE)

    assert_equal({ weather: WEATHER_RESPONSE }, WeatherReportCache.fetch(ZIP_06605))
    assert_equal({ weather: WEATHER_RESPONSE }, WeatherReportCache.fetch(ZIP_06605))

    assert_requested(stub, times: 1)
  end

  test "does not cache when response status is 500" do
    stub = stub_request(:get, "#{WeatherReport::SEARCH_URL}/#{ZIP_06605}")
           .with(query: WeatherReport::SEARCH_PARAMS)
           .to_return(status: 500)

    expected_error = "#{WeatherReport::ERROR_MESSAGE} #{ZIP_06605}"
    assert_equal({ error: expected_error }, WeatherReportCache.fetch(ZIP_06605))
    assert_equal({ error: expected_error }, WeatherReportCache.fetch(ZIP_06605))

    # Both calls should hit API again since errors aren't cached
    assert_requested(stub, times: 2)
  end

  test "cache expires after 30 minutes" do
    stub = stub_request(:get, "#{WeatherReport::SEARCH_URL}/#{ZIP_06605}")
           .with(query: WeatherReport::SEARCH_PARAMS)
           .to_return(body: WEATHER_RESPONSE)

    assert_equal({ weather: WEATHER_RESPONSE }, WeatherReportCache.fetch(ZIP_06605))

    travel 31.minutes

    assert_equal({ weather: WEATHER_RESPONSE }, WeatherReportCache.fetch(ZIP_06605))

    assert_requested(stub, times: 2)
  end
end 