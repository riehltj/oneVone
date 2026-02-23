class League < ApplicationRecord
  has_many :league_memberships, dependent: :destroy
  has_many :users, through: :league_memberships
  has_many :matches, dependent: :destroy
  has_many :payment_subscriptions, dependent: :destroy

  validates :name, :city, :region, presence: true
  validates :rating_min, :rating_max, presence: true
  validates :monthly_price_cents, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  def standings
    completed = matches.completed.includes(:challenger, :opponent, :winner)
    user_ids = league_memberships.pluck(:user_id).uniq
    user_ids.map do |user_id|
      user = User.find(user_id)
      wins = completed.count { |m| m.winner_id == user_id }
      played = completed.count { |m| m.challenger_id == user_id || m.opponent_id == user_id }
      losses = played - wins
      { user: user, wins: wins, losses: losses, games_played: played }
    end.sort_by { |h| [-h[:wins], h[:losses]] }
  end
end
