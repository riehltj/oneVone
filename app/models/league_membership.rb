class LeagueMembership < ApplicationRecord
  belongs_to :user
  belongs_to :league

  validates :user_id, uniqueness: { scope: :league_id }
  validates :dupr_rating, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 8 }, allow_nil: true
  validates :status, inclusion: { in: %w[active canceled] }

  validate :dupr_in_league_range, on: :create

  private

  def dupr_in_league_range
    return if dupr_rating.nil? || league.nil?
    return if dupr_rating >= league.rating_min && dupr_rating <= league.rating_max
    errors.add(:dupr_rating, "must be between #{league.rating_min} and #{league.rating_max} for this pool")
  end
end
