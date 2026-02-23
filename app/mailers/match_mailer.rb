# frozen_string_literal: true

class MatchMailer < ApplicationMailer
  def challenge_sent(match)
    @match = match
    @opponent = match.opponent
    @challenger = match.challenger
    @league = match.league
    mail(to: @opponent.email, subject: "#{@challenger.name.presence || @challenger.email} challenged you in #{@league.name}")
  end

  def challenge_accepted(match)
    @match = match
    @opponent = match.opponent
    @challenger = match.challenger
    @league = match.league
    mail(to: @challenger.email, subject: "#{@opponent.name.presence || @opponent.email} accepted your challenge in #{@league.name}")
  end

  def challenge_declined(match)
    @match = match
    @opponent = match.opponent
    @challenger = match.challenger
    @league = match.league
    mail(to: @challenger.email, subject: "#{@opponent.name.presence || @opponent.email} declined your challenge in #{@league.name}")
  end

  def match_reminder(match, recipient)
    @match = match
    @recipient = recipient
    @other = match.challenger_id == recipient.id ? match.opponent : match.challenger
    @league = match.league
    mail(to: recipient.email, subject: "Reminder: match tomorrow – #{@league.name}")
  end
end
