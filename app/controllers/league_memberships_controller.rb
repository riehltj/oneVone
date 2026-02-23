# frozen_string_literal: true

class LeagueMembershipsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_league

  def create
    dupr = membership_params[:dupr_rating]
    if stripe_configured?
      create_stripe_checkout_session(dupr)
    else
      create_membership_direct(dupr)
    end
  rescue Stripe::StripeError => e
    redirect_to league_path(@league), alert: e.message
  end

  def destroy
    membership = @league.league_memberships.find_by!(user: current_user)
    payment_sub = PaymentSubscription.find_by(user: current_user, league: @league)
    if payment_sub&.stripe_subscription_id.present?
      Stripe::Subscription.cancel(payment_sub.stripe_subscription_id) rescue nil
    end
    payment_sub&.destroy!
    membership.destroy!
    redirect_to league_path(@league), notice: "You left #{@league.name}."
  end

  private

  def set_league
    @league = League.find(params[:league_id])
  end

  def membership_params
    params.require(:league_membership).permit(:dupr_rating)
  end

  def stripe_configured?
    ENV["STRIPE_SECRET_KEY"].present?
  end

  def create_stripe_checkout_session(dupr)
    session = Stripe::Checkout::Session.create(
      mode: "subscription",
      customer_email: current_user.email,
      line_items: [{
        price_data: {
          currency: "usd",
          product_data: { name: "#{@league.name} — monthly" },
          unit_amount: @league.monthly_price_cents,
          recurring: { interval: "month" }
        },
        quantity: 1
      }],
      success_url: join_success_league_url(@league) + "?session_id={CHECKOUT_SESSION_ID}",
      cancel_url: league_url(@league),
      metadata: {
        "league_id" => @league.id.to_s,
        "user_id" => current_user.id.to_s,
        "dupr_rating" => dupr.to_s
      }
    )
    redirect_to session.url, allow_other_host: true
  end

  def create_membership_direct(dupr)
    @membership = @league.league_memberships.build(user: current_user, dupr_rating: dupr, status: "active")
    if @membership.save
      redirect_to league_path(@league), notice: "You joined #{@league.name}."
    else
      redirect_to league_path(@league), alert: @membership.errors.full_messages.to_sentence
    end
  end
end
