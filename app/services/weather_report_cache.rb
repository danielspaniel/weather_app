module WeatherReportCache
  CACHE_EXPIRATION = 30.minutes.freeze

  def self.fetch(address_or_zip)
    cache_key = "weather-report/#{address_or_zip}"
    Rails.cache.fetch(cache_key, expires_in: CACHE_EXPIRATION) do
      result = WeatherReport.new(address_or_zip).fetch
      raise result[:error] if result[:error]

      result
    end
  rescue StandardError => e
    { error: e.message }
  end
end