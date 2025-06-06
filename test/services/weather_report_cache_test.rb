require "test_helper"

class WeatherReportCacheTest < ActiveSupport::TestCase
  ZIP_06605 = "06605".freeze
  BRIDGEPORT_CT = "Bridgeport CT".freeze
  WEATHER_RESPONSE = "☀️   +22°C".freeze

  teardown do
    Rails.cache.clear
    travel_back
  end

  test "caches successful response" do
    stub = stub_request(:get, "#{WeatherReport::SEARCH_URL}/#{ZIP_06605}").with(
      query: WeatherReport::SEARCH_PARAMS
    ).to_return(body: WEATHER_RESPONSE)

    travel_to Time.current do
      expected_result = {
        weather: "#{ZIP_06605}: #{WEATHER_RESPONSE}",
        cached: false,
        cached_at: Time.current
      }
      assert_equal(expected_result, WeatherReportCache.fetch(ZIP_06605))

      expected_result[:cached] = true
      assert_equal(expected_result, WeatherReportCache.fetch(ZIP_06605))
    end

    assert_requested(stub, times: 1)
  end

  test "does not cache when response status is 500" do
    stub = stub_request(:get, "#{WeatherReport::SEARCH_URL}/#{ZIP_06605}").with(
      query: WeatherReport::SEARCH_PARAMS
    ).to_return(status: 500)

    expected_error = "#{WeatherReport::ERROR_MESSAGE} #{ZIP_06605}"
    assert_equal({ error: expected_error }, WeatherReportCache.fetch(ZIP_06605))
    assert_equal({ error: expected_error }, WeatherReportCache.fetch(ZIP_06605))

    # Both calls should hit API again since errors aren't cached
    assert_requested(stub, times: 2)
  end

  test "cache expires after 30 minutes" do
    stub = stub_request(:get, "#{WeatherReport::SEARCH_URL}/#{ZIP_06605}").with(
      query: WeatherReport::SEARCH_PARAMS
    ).to_return(body: WEATHER_RESPONSE)

    travel_to Time.current do
      expected_result = {
        weather: "#{ZIP_06605}: #{WEATHER_RESPONSE}",
        cached: false,
        cached_at: Time.current
      }
      assert_equal(expected_result, WeatherReportCache.fetch(ZIP_06605))
    end

    travel 31.minutes

    travel_to Time.current do
      expected_result = {
        weather: "#{ZIP_06605}: #{WEATHER_RESPONSE}",
        cached: false,
        cached_at: Time.current
      }
      assert_equal(expected_result, WeatherReportCache.fetch(ZIP_06605))
    end

    assert_requested(stub, times: 2)
  end
end 