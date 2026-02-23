# frozen_string_literal: true

require "test_helper"

class AvailabilityTest < ActiveSupport::TestCase
  test "DAYS constant has seven days" do
    assert_equal 7, Availability::DAYS.size
    assert_includes Availability::DAYS, "Monday"
    assert_includes Availability::DAYS, "Sunday"
  end

  test "validates day_of_week presence and inclusion" do
    a = Availability.new(user: users(:one), start_time: "17:30", end_time: "22:00")
    assert_not a.valid?
    assert a.errors[:day_of_week].any?
    a.day_of_week = "Notaday"
    assert_not a.valid?
    assert a.errors[:day_of_week].any?
  end

  test "validates start_time and end_time presence" do
    a = Availability.new(user: users(:one), day_of_week: "Monday")
    assert_not a.valid?
    assert a.errors[:start_time].any?
    assert a.errors[:end_time].any?
  end

  test "end_after_start adds error when end_time <= start_time" do
    a = Availability.new(user: users(:one), day_of_week: "Monday", start_time: "22:00", end_time: "17:30")
    assert_not a.valid?
    assert a.errors[:end_time].any?
  end

  test "valid when end_time after start_time" do
    a = Availability.new(user: users(:one), day_of_week: "Monday", start_time: "17:30", end_time: "22:00")
    assert a.valid?
  end

  test "belongs to user" do
    a = availabilities(:one)
    assert a.user.present?
  end
end
