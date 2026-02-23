# frozen_string_literal: true

require "test_helper"

class LeaguesControllerTest < ActionDispatch::IntegrationTest
  test "get index without sign in" do
    get leagues_url
    assert_response :success
    assert_select "h1", text: /Denver Pools/
  end

  test "get index when signed in" do
    sign_in users(:one)
    get leagues_url
    assert_response :success
  end

  test "get show without sign in" do
    league = leagues(:one)
    get league_url(league)
    assert_response :success
    assert_select "h1", text: league.name
  end

  test "get show when signed in as member" do
    sign_in users(:one)
    league = leagues(:one)
    get league_url(league)
    assert_response :success
    assert_match /in this pool/, response.body
  end

  test "get show when signed in as non-member" do
    sign_in users(:three)
    league = leagues(:one)
    get league_url(league)
    assert_response :success
    assert_match /Join this pool/, response.body
  end

  test "join_success redirects when session_id missing" do
    sign_in users(:one)
    get join_success_league_url(leagues(:one))
    assert_redirected_to leagues_path
    assert_match /Missing session/, flash[:alert]
  end

  test "join_success redirects when stripe not configured" do
    sign_in users(:one)
    get join_success_league_url(leagues(:one)), params: { session_id: "cs_xxx" }
    assert_redirected_to leagues_path
  end

  test "join_success rescues when Stripe raises" do
    sign_in users(:one)
    orig = ENV["STRIPE_SECRET_KEY"]
    begin
      ENV["STRIPE_SECRET_KEY"] = "sk_test_xxx"
      get join_success_league_url(leagues(:one)), params: { session_id: "cs_invalid_123" }
      assert_redirected_to leagues_path
      assert flash[:alert].present?
    ensure
      ENV["STRIPE_SECRET_KEY"] = orig
    end
  end
end
