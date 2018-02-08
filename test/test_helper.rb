ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../../config/environment", __FILE__)
require "rails/test_help"
require "minitest/reporters"
Minitest::Reporters.use!

module ActiveSupport
  class TestCase
    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical.
    fixtures :all
    include ApplicationHelper

    # Returns true if a test user is logged in.
    def is_logged_in?
      session[:user_id].present?
    end
  end
end
