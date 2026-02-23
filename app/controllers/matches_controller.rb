# frozen_string_literal: true

class MatchesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_match, only: %i[update]

  def create
    @league = League.find(params[:league_id])
    opponent = User.find(match_params[:opponent_id])
    @match = @league.matches.build(
      challenger: current_user,
      opponent: opponent,
      status: "pending",
      scheduled_at: match_params[:scheduled_at].presence,
      location: match_params[:location].presence
    )
    if @match.save
      MatchMailer.challenge_sent(@match).deliver_later
      redirect_to league_path(@league), notice: "Challenge sent to #{opponent.name.presence || opponent.email}."
    else
      redirect_to league_path(@league), alert: @match.errors.full_messages.to_sentence
    end
  end

  def update
    if @match.opponent_id != current_user.id && @match.challenger_id != current_user.id
      return redirect_to dashboard_path, alert: "Not authorized to update this match."
    end

    case match_params[:status]
    when "accepted", "declined"
      unless @match.opponent_id == current_user.id
        return redirect_to dashboard_path, alert: "Only the opponent can accept or decline."
      end
      if @match.update(status: match_params[:status])
        if match_params[:status] == "accepted"
          MatchMailer.challenge_accepted(@match).deliver_later
          if @match.scheduled_at.present? && @match.scheduled_at > Time.current
            run_at = [@match.scheduled_at - 24.hours, Time.current].max
            MatchReminderJob.set(wait_until: run_at).perform_later(@match)
          end
        else
          MatchMailer.challenge_declined(@match).deliver_later
        end
        redirect_to dashboard_path, notice: "Challenge #{match_params[:status]}."
      else
        redirect_to dashboard_path, alert: @match.errors.full_messages.to_sentence
      end
    when "completed"
      unless @match.status == "accepted"
        return redirect_to dashboard_path, alert: "Match must be accepted before reporting a result."
      end
      if @match.update(status: "completed", winner_id: match_params[:winner_id], score: match_params[:score])
        redirect_to dashboard_path, notice: "Result recorded."
      else
        redirect_to dashboard_path, alert: @match.errors.full_messages.to_sentence
      end
    else
      redirect_to dashboard_path, alert: "Invalid action."
    end
  end

  private

  def set_match
    @match = Match.find(params[:id])
  end

  def match_params
    params.require(:match).permit(:opponent_id, :status, :winner_id, :score, :scheduled_at, :location)
  end
end
