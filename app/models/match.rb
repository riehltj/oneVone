class Match < ApplicationRecord
  STATUSES = %w[pending accepted declined completed].freeze

  belongs_to :league
  belongs_to :challenger, class_name: "User"
  belongs_to :opponent, class_name: "User"
  belongs_to :winner, class_name: "User", optional: true

  validates :status, inclusion: { in: STATUSES }
  scope :pending, -> { where(status: "pending") }
  scope :completed, -> { where(status: "completed") }
  validate :challenger_and_opponent_different
  validate :both_in_league

  private

  def challenger_and_opponent_different
    errors.add(:opponent_id, "can't challenge yourself") if challenger_id.present? && opponent_id.present? && challenger_id == opponent_id
  end

  def both_in_league
    return if league.blank?
    return unless challenger_id.present? && opponent_id.present?
    unless league.league_memberships.exists?(user_id: challenger_id) && league.league_memberships.exists?(user_id: opponent_id)
      errors.add(:base, "Both players must be in this league")
    end
  end
end
