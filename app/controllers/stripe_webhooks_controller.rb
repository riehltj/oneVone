# frozen_string_literal: true

class StripeWebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :load_stripe_event
  rescue_from Stripe::SignatureVerificationError, with: :signature_invalid

  def create
    event = @stripe_event
    return head :ok unless event
    case event.type
    when "customer.subscription.updated", "customer.subscription.deleted"
      sub = event.data.object
      payment_sub = PaymentSubscription.find_by(stripe_subscription_id: sub.id)
      if payment_sub
        status = (event.type == "customer.subscription.deleted") ? "canceled" : sub.status
        payment_sub.update!(status: status)
      end
    end
    head :ok
  rescue ActiveRecord::RecordInvalid
    head :ok
  end

  private

  def load_stripe_event
    payload = request.body.read
    return @stripe_event = nil if payload.blank?
    sig = request.env["HTTP_STRIPE_SIGNATURE"]
    @stripe_event = if ENV["STRIPE_WEBHOOK_SECRET"].present?
      Stripe::Webhook.construct_event(payload, sig, ENV["STRIPE_WEBHOOK_SECRET"])
    else
      Stripe::Event.construct_from(JSON.parse(payload))
    end
  end

  def signature_invalid
    head :bad_request
  end
end
