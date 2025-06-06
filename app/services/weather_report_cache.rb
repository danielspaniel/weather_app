module WeatherReportCache
  CACHE_EXPIRATION = 30.minutes.freeze

  def self.fetch(address_or_zip)
    cache_key = "weather-report/#{address_or_zip}"
    from_cache = true
    cache_result = Rails.cache.fetch(cache_key, expires_in: CACHE_EXPIRATION) do
      from_cache = false
      result = WeatherReport.fetch(address_or_zip)
      raise result[:error] if result[:error]

      result.merge(cached_at: Time.current)
    end
    cache_result.merge(cached: from_cache)
  rescue StandardError => e
    { error: e.message }
  end
end