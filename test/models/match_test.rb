# frozen_string_literal: true

require "test_helper"

class MatchTest < ActiveSupport::TestCase
  test "STATUSES constant" do
    assert_includes Match::STATUSES, "pending"
    assert_includes Match::STATUSES, "accepted"
    assert_includes Match::STATUSES, "declined"
    assert_includes Match::STATUSES, "completed"
  end

  test "validates status inclusion" do
    m = matches(:one)
    m.status = "invalid"
    assert_not m.valid?
    assert m.errors[:status].any?
  end

  test "challenger_and_opponent_different adds error when same user" do
    league = leagues(:one)
    user = users(:one)
    m = Match.new(league: league, challenger: user, opponent: user, status: "pending")
    assert_not m.valid?
    assert m.errors[:opponent_id].any?
  end

  test "both_in_league adds error when challenger not in league" do
    league = League.create!(name: "Temp", city: "Denver", region: "CO", rating_min: 4.0, rating_max: 4.5)
    LeagueMembership.create!(user: users(:two), league: league, dupr_rating: 4.2, status: "active")
    challenger = users(:three)
    opponent = users(:two)
    m = Match.new(league: league, challenger: challenger, opponent: opponent, status: "pending")
    assert_not m.valid?
    assert m.errors[:base].any?
  end

  test "both_in_league adds error when opponent not in league" do
    league = League.create!(name: "Temp2", city: "Denver", region: "CO", rating_min: 4.0, rating_max: 4.5)
    LeagueMembership.create!(user: users(:one), league: league, dupr_rating: 4.2, status: "active")
    challenger = users(:one)
    opponent = users(:three)
    m = Match.new(league: league, challenger: challenger, opponent: opponent, status: "pending")
    assert_not m.valid?
    assert m.errors[:base].any?
  end

  test "valid when both in league and different users" do
    m = matches(:one)
    assert m.valid?
  end

  test "pending scope" do
    pending = Match.pending
    assert pending.where(status: "pending").count == pending.count
  end

  test "completed scope" do
    completed = Match.completed
    assert completed.where(status: "completed").count == completed.count
  end

  test "belongs to league challenger opponent winner" do
    m = matches(:three)
    assert m.league.present?
    assert m.challenger.present?
    assert m.opponent.present?
    assert m.winner.present?
  end
end
