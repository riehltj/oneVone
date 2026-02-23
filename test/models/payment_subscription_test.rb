# frozen_string_literal: true

require "test_helper"

class PaymentSubscriptionTest < ActiveSupport::TestCase
  test "validates status inclusion" do
    ps = payment_subscriptions(:one)
    ps.status = "invalid"
    assert_not ps.valid?
    assert ps.errors[:status].any?
  end

  test "allows active canceled past_due" do
    %w[active canceled past_due].each do |status|
      ps = PaymentSubscription.new(user: users(:one), league: leagues(:two), status: status)
      assert ps.valid?, "status #{status} should be valid"
    end
  end

  test "belongs to user and league" do
    ps = payment_subscriptions(:one)
    assert ps.user.present?
    assert ps.league.present?
  end
end
