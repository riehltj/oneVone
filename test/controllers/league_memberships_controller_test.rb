# frozen_string_literal: true

require "test_helper"

class LeagueMembershipsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @league = leagues(:one)
    @user = users(:three)
  end

  test "create requires sign in" do
    assert_no_difference "LeagueMembership.count" do
      post league_membership_url(@league), params: { league_membership: { dupr_rating: 4.2 } }
    end
    assert_redirected_to new_user_session_url
  end

  test "create adds membership when signed in and stripe not configured" do
    sign_in @user
    assert_difference "LeagueMembership.count", 1 do
      post league_membership_url(@league), params: { league_membership: { dupr_rating: 4.2 } }
    end
    assert_redirected_to league_path(@league)
    assert_match /joined/, flash[:notice]
    assert @league.league_memberships.exists?(user_id: @user.id)
  end

  test "create redirects with alert when dupr out of range" do
    sign_in @user
    assert_no_difference "LeagueMembership.count" do
      post league_membership_url(@league), params: { league_membership: { dupr_rating: 3.0 } }
    end
    assert_redirected_to league_path(@league)
    assert flash[:alert].present?
  end

  test "create with stripe configured rescues StripeError and redirects with alert" do
    sign_in @user
    orig = ENV["STRIPE_SECRET_KEY"]
    ENV["STRIPE_SECRET_KEY"] = "sk_test_xxx"
    post league_membership_url(@league), params: { league_membership: { dupr_rating: 4.2 } }
    assert_redirected_to league_path(@league)
    assert flash[:alert].present?
  ensure
    ENV["STRIPE_SECRET_KEY"] = orig
  end

  test "destroy removes membership and payment_subscription" do
    sign_in users(:one)
    membership = league_memberships(:one)
    league = membership.league
    assert_difference "LeagueMembership.count", -1 do
      assert_difference "PaymentSubscription.count", -1 do
        delete league_membership_url(league)
      end
    end
    assert_redirected_to league_path(league)
    assert_match /left/, flash[:notice]
  end
end
