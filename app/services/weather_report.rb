class WeatherReport
  SEARCH_URL = "https://wttr.in".freeze
  SEARCH_PARAMS = { format: 3 }.freeze
  ERROR_MESSAGE = "Could not get weather for that location: ".freeze

  def initialize(address_or_zip)
    @address_or_zip = address_or_zip
  end

  def fetch
    response = make_request(@address_or_zip)
    return success_response(response) if response.success?

    { error: error_message }
  rescue StandardError => e
    { error: e.message }
  end

  private

  def make_request(address_or_zip)
    encoded_location = URI.encode_www_form_component(address_or_zip)
    url = "#{SEARCH_URL}/#{encoded_location}"
    Faraday.get(url, SEARCH_PARAMS)
  end

  def success_response(response)
    weather_without_location = response.body.split(":", 2)[1]
    { weather: "#{@address_or_zip}:#{weather_without_location}" }
  end

  def error_message
    "#{ERROR_MESSAGE} #{@address_or_zip}"
  end
end
