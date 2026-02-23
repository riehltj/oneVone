# frozen_string_literal: true

require "test_helper"

class LeagueTest < ActiveSupport::TestCase
  test "validates name city region presence" do
    league = League.new(rating_min: 4.0, rating_max: 4.5)
    assert_not league.valid?
    assert league.errors[:name].any?
    assert league.errors[:city].any?
    assert league.errors[:region].any?
  end

  test "validates rating_min and rating_max presence" do
    league = League.new(name: "Test", city: "Denver", region: "CO")
    assert_not league.valid?
    assert league.errors[:rating_min].any?
    assert league.errors[:rating_max].any?
  end

  test "validates monthly_price_cents numericality when present" do
    league = League.new(name: "Test", city: "Denver", region: "CO", rating_min: 4.0, rating_max: 4.5, monthly_price_cents: -1)
    assert_not league.valid?
    assert league.errors[:monthly_price_cents].any?
  end

  test "allows nil monthly_price_cents" do
    league = League.new(name: "Test", city: "Denver", region: "CO", rating_min: 4.0, rating_max: 4.5)
    assert league.valid?
  end

  test "has many league_memberships and users" do
    league = leagues(:one)
    assert league.league_memberships.any?
    assert league.users.any?
  end

  test "has many matches and payment_subscriptions" do
    league = leagues(:one)
    assert_respond_to league, :matches
    assert_respond_to league, :payment_subscriptions
  end

  test "standings returns array of hashes with user wins losses games_played" do
    league = leagues(:one)
    standings = league.standings
    assert_kind_of Array, standings
    standings.each do |row|
      assert row.key?(:user)
      assert row.key?(:wins)
      assert row.key?(:losses)
      assert row.key?(:games_played)
      assert row[:user].is_a?(User)
    end
  end

  test "standings sorted by wins desc then losses asc" do
    league = leagues(:one)
    standings = league.standings
    (0...standings.length - 1).each do |i|
      assert standings[i][:wins] >= standings[i + 1][:wins]
      if standings[i][:wins] == standings[i + 1][:wins]
        assert standings[i][:losses] <= standings[i + 1][:losses]
      end
    end
  end
end
