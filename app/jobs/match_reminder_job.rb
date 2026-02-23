# frozen_string_literal: true

class MatchReminderJob < ApplicationJob
  queue_as :default

  def perform(match)
    return if match.reminder_sent_at.present?
    return unless match.status == "accepted" && match.scheduled_at.present?
    return if match.scheduled_at.past?

    [match.challenger, match.opponent].each do |recipient|
      MatchMailer.match_reminder(match, recipient).deliver_later
    end
    match.update_columns(reminder_sent_at: Time.current)
  end
end
