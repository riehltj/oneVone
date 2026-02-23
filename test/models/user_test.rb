# frozen_string_literal: true

require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "ZONES constant has four Denver zones" do
    assert_equal 4, User::ZONES.size
    assert_includes User::ZONES, "North Denver"
    assert_includes User::ZONES, "South Denver"
    assert_includes User::ZONES, "East Denver"
    assert_includes User::ZONES, "West Denver"
  end

  test "user has league_memberships" do
    user = users(:one)
    assert_respond_to user, :league_memberships
    assert user.league_memberships.any?
  end

  test "user has leagues through league_memberships" do
    user = users(:one)
    assert_respond_to user, :leagues
    assert user.leagues.any?
  end

  test "user has availabilities" do
    user = users(:one)
    assert_respond_to user, :availabilities
    assert user.availabilities.any?
  end

  test "user has challenges_sent and challenges_received" do
    user = users(:one)
    assert_respond_to user, :challenges_sent
    assert_respond_to user, :challenges_received
  end

  test "user has payment_subscriptions" do
    user = users(:one)
    assert_respond_to user, :payment_subscriptions
  end
end
