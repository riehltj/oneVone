# frozen_string_literal: true

require "test_helper"

class StripeWebhooksControllerTest < ActionDispatch::IntegrationTest
  test "create returns ok when payload blank" do
    post stripe_webhook_url, params: {}
    assert_response :ok
  end

  test "create parses event when no webhook secret and updates subscription" do
    ps = payment_subscriptions(:one)
    payload = {
      type: "customer.subscription.updated",
      data: { object: { id: ps.stripe_subscription_id, status: "past_due" } }
    }
    post stripe_webhook_url, params: payload, as: :json
    assert_response :ok
    ps.reload
    assert_equal "past_due", ps.status
  end

  test "create handles customer.subscription.deleted" do
    ps = payment_subscriptions(:one)
    payload = {
      type: "customer.subscription.deleted",
      data: { object: { id: ps.stripe_subscription_id } }
    }
    post stripe_webhook_url, params: payload, as: :json
    assert_response :ok
    ps.reload
    assert_equal "canceled", ps.status
  end

  test "create returns ok for unknown event type" do
    post stripe_webhook_url, params: { type: "unknown.event", data: {} }, as: :json
    assert_response :ok
  end

  test "create returns bad_request when webhook secret set and signature invalid" do
    orig = ENV["STRIPE_WEBHOOK_SECRET"]
    ENV["STRIPE_WEBHOOK_SECRET"] = "whsec_xxx"
    post stripe_webhook_url, params: { type: "customer.subscription.updated", data: {} }.to_json, headers: { "CONTENT_TYPE" => "application/json", "HTTP_STRIPE_SIGNATURE" => "invalid" }
    assert_response :bad_request
  ensure
    ENV["STRIPE_WEBHOOK_SECRET"] = orig
  end
end
