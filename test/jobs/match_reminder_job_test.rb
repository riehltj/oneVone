# frozen_string_literal: true

require "test_helper"

class MatchReminderJobTest < ActiveJob::TestCase
  setup do
    @match = matches(:two)
    @match.update!(scheduled_at: 2.days.from_now, location: "City Park", reminder_sent_at: nil)
    ActionMailer::Base.deliveries.clear
  end

  test "sends reminder to both players and sets reminder_sent_at" do
    MatchReminderJob.perform_now(@match)
    perform_enqueued_jobs
    assert_equal 2, ActionMailer::Base.deliveries.size
    assert @match.reload.reminder_sent_at.present?
  end

  test "no-op when reminder_sent_at already set" do
    @match.update_columns(reminder_sent_at: 1.hour.ago)
    assert_no_difference "ActionMailer::Base.deliveries.size" do
      MatchReminderJob.perform_now(@match)
      perform_enqueued_jobs
    end
  end

  test "no-op when match not accepted" do
    @match.update!(status: "pending")
    assert_no_difference "ActionMailer::Base.deliveries.size" do
      MatchReminderJob.perform_now(@match)
      perform_enqueued_jobs
    end
  end

  test "no-op when scheduled_at in past" do
    @match.update!(scheduled_at: 1.hour.ago)
    assert_no_difference "ActionMailer::Base.deliveries.size" do
      MatchReminderJob.perform_now(@match)
      perform_enqueued_jobs
    end
  end
end
