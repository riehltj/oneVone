# frozen_string_literal: true

require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "get root when not signed in" do
    get root_url
    assert_response :success
    assert_select "a", text: /Sign in/
    assert_select "a", text: /Browse Denver pools|pools/
  end

  test "get root when signed in" do
    sign_in users(:one)
    get root_url
    assert_response :success
    assert_match /Dashboard/, response.body
    assert_match /Sign out/, response.body
  end
end
