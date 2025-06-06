ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

require "minitest"
require "minitest/autorun"
require "minitest/reporters"
require "webmock/minitest"

# Configure Minitest reporters
Minitest::Reporters.use! [
  Minitest::Reporters::SpecReporter.new
]

# Configure cache store for tests
Rails.cache = ActiveSupport::Cache::MemoryStore.new

module ActiveSupport
  class TestCase
    parallelize(workers: :number_of_processors)
  end
end
