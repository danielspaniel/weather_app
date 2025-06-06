require "test_helper"

class WeatherFlowTest < ActionDispatch::IntegrationTest
  ZIP_06605 = "06605".freeze
  ZIP_06605_WEATHER_RESPONSE = "06605: ☀️ +22°C".freeze

  teardown do
    Rails.cache.clear
  end

  test "can get weather for a zip code" do
    stub_request(:get, "#{WeatherReport::SEARCH_URL}/#{ZIP_06605}")
      .with(query: WeatherReport::SEARCH_PARAMS)
      .to_return(body: ZIP_06605_WEATHER_RESPONSE)

    get root_path
    assert_select "h1", "Weather Report"
    assert_select "input[type=text][name=address_or_zip]"
    assert_select "input[type=submit][value='Get Weather']"

    get weather_path, params: { address_or_zip: ZIP_06605 }

    assert_response :success
    assert_select ".weather-report", "Weather for #{ZIP_06605_WEATHER_RESPONSE} [ Fresh result ]"
  end

  test "shows error for invalid location" do
    stub_request(:get, "#{WeatherReport::SEARCH_URL}/invalid")
      .with(query: WeatherReport::SEARCH_PARAMS)
      .to_return(status: 404)

    get weather_path, params: { address_or_zip: "invalid" }

    assert_response :success
    assert_select ".error", text: /#{WeatherReport::ERROR_MESSAGE}/
  end
end