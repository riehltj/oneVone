# frozen_string_literal: true

require "test_helper"

class MatchesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @league = leagues(:one)
    @match = matches(:one)
  end

  test "create requires sign in" do
    assert_no_difference "Match.count" do
      post league_matches_url(@league), params: { match: { opponent_id: users(:two).id } }
    end
    assert_redirected_to new_user_session_url
  end

  test "create adds match when signed in" do
    sign_in users(:one)
    assert_difference "Match.count", 1 do
      post league_matches_url(@league), params: { match: { opponent_id: users(:two).id } }
    end
    assert_redirected_to league_path(@league)
    assert_match /Challenge sent/, flash[:notice]
  end

  test "update accept as opponent" do
    sign_in users(:two)
    patch match_url(@match), params: { match: { status: "accepted" } }
    assert_redirected_to dashboard_path
    @match.reload
    assert_equal "accepted", @match.status
  end

  test "update decline as opponent" do
    sign_in users(:two)
    patch match_url(@match), params: { match: { status: "declined" } }
    assert_redirected_to dashboard_path
    @match.reload
    assert_equal "declined", @match.status
  end

  test "update completed as challenger with winner" do
    accepted = matches(:two)
    sign_in users(:one)
    patch match_url(accepted), params: { match: { status: "completed", winner_id: users(:one).id, score: "11-9" } }
    assert_redirected_to dashboard_path
    accepted.reload
    assert_equal "completed", accepted.status
    assert_equal users(:one).id, accepted.winner_id
  end

  test "update reject when not participant" do
    sign_in users(:three)
    patch match_url(@match), params: { match: { status: "accepted" } }
    assert_redirected_to dashboard_path
    assert_match /Not authorized/, flash[:alert]
  end

  test "update reject accept when not opponent" do
    sign_in users(:one)
    patch match_url(@match), params: { match: { status: "accepted" } }
    assert_redirected_to dashboard_path
    assert_match /Only the opponent/, flash[:alert]
  end

  test "update completed rejects when match not accepted" do
    sign_in users(:one)
    patch match_url(@match), params: { match: { status: "completed", winner_id: users(:one).id } }
    assert_redirected_to dashboard_path
    assert_match /must be accepted before reporting a result/, flash[:alert]
  end

  test "update with invalid status" do
    sign_in users(:two)
    patch match_url(@match), params: { match: { status: "invalid" } }
    assert_redirected_to dashboard_path
    assert_match /Invalid action/, flash[:alert]
  end
end
