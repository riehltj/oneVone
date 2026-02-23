class User < ApplicationRecord
  ZONES = [
    "North Denver",
    "South Denver",
    "East Denver",
    "West Denver"
  ].freeze

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :league_memberships, dependent: :destroy
  has_many :leagues, through: :league_memberships
  has_many :availabilities, dependent: :destroy
  has_many :challenges_sent, class_name: "Match", foreign_key: :challenger_id, dependent: :destroy
  has_many :challenges_received, class_name: "Match", foreign_key: :opponent_id, dependent: :destroy
  has_many :payment_subscriptions, dependent: :destroy
end
