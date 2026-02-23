# frozen_string_literal: true

require "test_helper"

class LeagueMembershipTest < ActiveSupport::TestCase
  test "validates user_id uniqueness scoped to league_id" do
    existing = league_memberships(:one)
    dup = LeagueMembership.new(user_id: existing.user_id, league_id: existing.league_id, dupr_rating: 4.0, status: "active")
    assert_not dup.valid?
    assert dup.errors[:user_id].any?
  end

  test "validates dupr_rating in range 0 to 8 when present" do
    league = leagues(:one)
    m = LeagueMembership.new(user: users(:three), league: league, dupr_rating: -0.1, status: "active")
    assert_not m.valid?
    assert m.errors[:dupr_rating].any?
    m.dupr_rating = 9
    assert_not m.valid?
    assert m.errors[:dupr_rating].any?
  end

  test "allows nil dupr_rating" do
    league = leagues(:two)
    m = LeagueMembership.new(user: users(:one), league: league, status: "active")
    m.dupr_rating = nil
    m.league = league
    assert m.valid?
  end

  test "validates status inclusion" do
    m = league_memberships(:one)
    m.status = "invalid"
    assert_not m.valid?
    assert m.errors[:status].any?
  end

  test "dupr_in_league_range adds error when dupr outside league range on create" do
    league = leagues(:one)
    m = LeagueMembership.new(user: users(:three), league: league, dupr_rating: 3.0, status: "active")
    assert_not m.valid?
    assert m.errors[:dupr_rating].any?
    assert_match /between 4.0 and 4.5/, m.errors[:dupr_rating].first
  end

  test "dupr_in_league_range allows dupr within league range" do
    league = leagues(:one)
    m = LeagueMembership.new(user: users(:three), league: league, dupr_rating: 4.2, status: "active")
    assert m.valid?
  end

  test "belongs to user and league" do
    m = league_memberships(:one)
    assert m.user.present?
    assert m.league.present?
  end
end
