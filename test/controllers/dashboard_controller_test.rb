# frozen_string_literal: true

require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  test "show requires sign in" do
    get dashboard_url
    assert_redirected_to new_user_session_url
  end

  test "show when signed in" do
    sign_in users(:one)
    get dashboard_url
    assert_response :success
    assert_match /Dashboard/, response.body
    assert_match /My pools|availability|Profile/, response.body
  end
end
