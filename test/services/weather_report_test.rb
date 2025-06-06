require "test_helper"

class WeatherReportTest < ActiveSupport::TestCase
  ZIP_06605 = "06605".freeze
  BRIDGEPORT_CT = "Bridgeport CT".freeze
  ZIP_WEATHER_RESPONSE = "☀️ +22°C".freeze
  CITY_WEATHER_RESPONSE = "☀️ +22°C".freeze

  test "fetch when successful using zip" do
    stub_request(:get, "#{WeatherReport::SEARCH_URL}/#{ZIP_06605}")
      .with(query: WeatherReport::SEARCH_PARAMS)
      .to_return(body: ZIP_WEATHER_RESPONSE)

    result = WeatherReport.fetch(ZIP_06605)

    assert_equal({ weather: "#{ZIP_06605}: #{ZIP_WEATHER_RESPONSE}" }, result)
  end

  test "fetch when successful using city state" do
    stub_request(:get, "#{WeatherReport::SEARCH_URL}/#{URI.encode_www_form_component(BRIDGEPORT_CT)}")
      .with(query: WeatherReport::SEARCH_PARAMS)
      .to_return(body: CITY_WEATHER_RESPONSE)

    result = WeatherReport.fetch(BRIDGEPORT_CT)

    assert_equal({ weather: "Bridgeport CT: ☀️ +22°C" }, result)
  end

  test "fetch when 500 failure" do
    stub_request(:get, "#{WeatherReport::SEARCH_URL}/#{ZIP_06605}")
      .with(query: WeatherReport::SEARCH_PARAMS)
      .to_return(status: 500)

    result = WeatherReport.fetch(ZIP_06605)

    assert_equal({ error: "#{WeatherReport::ERROR_MESSAGE} #{ZIP_06605}" }, result)
  end

  test "fetch when exception raised" do
    stub_request(:get, "#{WeatherReport::SEARCH_URL}/#{ZIP_06605}")
      .with(query: WeatherReport::SEARCH_PARAMS)
      .to_raise(StandardError.new("Bad Request"))

    result = WeatherReport.fetch(ZIP_06605)

    assert_equal({ error: "Bad Request" }, result)
  end
end
