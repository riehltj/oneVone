# frozen_string_literal: true

require "test_helper"

class MatchMailerTest < ActionMailer::TestCase
  setup do
    @match = matches(:one)
    @match.update!(scheduled_at: 1.day.from_now, location: "Wash Park")
  end

  test "challenge_sent" do
    email = MatchMailer.challenge_sent(@match)
    assert_emails 1 do
      email.deliver_now
    end
    assert_equal [@match.opponent.email], email.to
    assert_includes email.body.encoded, @match.challenger.name
    assert_includes email.body.encoded, "Denver 4.0"
    assert_includes email.body.encoded, "Wash Park"
  end

  test "challenge_accepted" do
    @match.update!(status: "accepted")
    email = MatchMailer.challenge_accepted(@match)
    assert_emails 1 do
      email.deliver_now
    end
    assert_equal [@match.challenger.email], email.to
    assert_includes email.body.encoded, @match.opponent.name
  end

  test "challenge_declined" do
    @match.update!(status: "declined")
    email = MatchMailer.challenge_declined(@match)
    assert_emails 1 do
      email.deliver_now
    end
    assert_equal [@match.challenger.email], email.to
  end

  test "match_reminder" do
    @match.update!(status: "accepted")
    email = MatchMailer.match_reminder(@match, @match.challenger)
    assert_emails 1 do
      email.deliver_now
    end
    assert_equal [@match.challenger.email], email.to
    assert_includes email.body.encoded, "February"
    assert_includes email.body.encoded, "Wash Park"
  end
end
