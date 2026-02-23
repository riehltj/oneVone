# frozen_string_literal: true

class LeaguesController < ApplicationController
  before_action :authenticate_user!, only: [:join_success]

  def index
    @leagues = League.order(:rating_min, :rating_max)
  end

  def show
    @league = League.find(params[:id])
    @current_membership = current_user && @league.league_memberships.find_by(user: current_user)
    @standings = @league.standings
  end

  def join_success
    session_id = params[:session_id]
    return redirect_to leagues_path, alert: "Missing session." unless session_id.present? && ENV["STRIPE_SECRET_KEY"].present?

    stripe_session = Stripe::Checkout::Session.retrieve(session_id)
    meta = stripe_session.metadata
    return redirect_to leagues_path, alert: "Invalid session." unless meta["user_id"].to_s == current_user.id.to_s

    league = League.find(meta["league_id"])
    dupr = meta["dupr_rating"].presence
    membership = league.league_memberships.build(user: current_user, dupr_rating: dupr, status: "active")
    membership.save!
    PaymentSubscription.create!(user: current_user, league: league, stripe_subscription_id: stripe_session.subscription, status: "active")
    redirect_to league_path(league), notice: "You joined #{league.name}. Payment successful."
  rescue ActiveRecord::RecordInvalid, Stripe::StripeError => e
    redirect_to leagues_path, alert: e.message
  end
end
