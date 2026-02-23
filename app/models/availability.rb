class Availability < ApplicationRecord
  DAYS = %w[Monday Tuesday Wednesday Thursday Friday Saturday Sunday].freeze

  belongs_to :user

  validates :day_of_week, presence: true, inclusion: { in: DAYS }
  validates :start_time, :end_time, presence: true
  validate :end_after_start

  private

  def end_after_start
    return if start_time.blank? || end_time.blank?
    errors.add(:end_time, "must be after start time") if end_time <= start_time
  end
end
