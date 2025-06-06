module WeatherHelper
  def cache_status_display(weather)
    if weather[:cached]
      "Cached at: #{weather[:cached_at].strftime('%B %d, %Y at %I:%M %p')}"
    else
      "[ Fresh result ]"
    end
  end
end 