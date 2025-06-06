class WeatherController < ApplicationController
  def index; end

  def show
    @address_or_zip = params[:address_or_zip]
    @weather = WeatherReportCache.fetch(@address_or_zip)
  end
end