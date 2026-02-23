# frozen_string_literal: true

require "test_helper"

class AvailabilitiesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @availability = availabilities(:one)
  end

  test "index requires sign in" do
    get availabilities_url
    assert_redirected_to new_user_session_url
  end

  test "index when signed in" do
    sign_in @user
    get availabilities_url
    assert_response :success
  end

  test "new requires sign in" do
    get new_availability_url
    assert_redirected_to new_user_session_url
  end

  test "new when signed in" do
    sign_in @user
    get new_availability_url
    assert_response :success
  end

  test "create requires sign in" do
    assert_no_difference "Availability.count" do
      post availabilities_url, params: { availability: { day_of_week: "Monday", start_time: "18:00", end_time: "21:00" } }
    end
    assert_redirected_to new_user_session_url
  end

  test "create when signed in" do
    sign_in @user
    assert_difference "Availability.count", 1 do
      post availabilities_url, params: { availability: { day_of_week: "Monday", start_time: "18:00", end_time: "21:00" } }
    end
    assert_redirected_to availabilities_path
    assert_match /added/, flash[:notice]
  end

  test "create render new when invalid" do
    sign_in @user
    assert_no_difference "Availability.count" do
      post availabilities_url, params: { availability: { day_of_week: "Monday", start_time: "21:00", end_time: "18:00" } }
    end
    assert_response :unprocessable_entity
  end

  test "edit requires sign in" do
    get edit_availability_url(@availability)
    assert_redirected_to new_user_session_url
  end

  test "edit when signed in" do
    sign_in @user
    get edit_availability_url(@availability)
    assert_response :success
  end

  test "update when signed in" do
    sign_in @user
    patch availability_url(@availability), params: { availability: { day_of_week: "Wednesday", start_time: "17:30", end_time: "22:00" } }
    assert_redirected_to availabilities_path
    @availability.reload
    assert_equal "Wednesday", @availability.day_of_week
  end

  test "destroy when signed in" do
    sign_in @user
    assert_difference "Availability.count", -1 do
      delete availability_url(@availability)
    end
    assert_redirected_to availabilities_path
  end

  test "edit another user availability returns 404" do
    sign_in users(:two)
    get edit_availability_url(availabilities(:one))
    assert_response :not_found
  end

  test "update another user availability returns 404" do
    sign_in users(:two)
    patch availability_url(availabilities(:one)), params: { availability: { day_of_week: "Monday", start_time: "18:00", end_time: "21:00" } }
    assert_response :not_found
  end
end
