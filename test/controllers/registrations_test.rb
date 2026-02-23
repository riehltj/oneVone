# frozen_string_literal: true

require "test_helper"

class RegistrationsTest < ActionDispatch::IntegrationTest
  test "sign up permits name zone can_host" do
    get new_user_registration_path
    assert_response :success
    post user_registration_path, params: {
      user: {
        name: "New User",
        email: "new@example.com",
        password: "password123",
        password_confirmation: "password123",
        zone: "North Denver",
        can_host: "1"
      }
    }
    assert_redirected_to root_path
    user = User.find_by(email: "new@example.com")
    assert user
    assert_equal "New User", user.name
    assert_equal "North Denver", user.zone
    assert user.can_host?
  end

  test "account update permits name zone can_host" do
    sign_in users(:one)
    get edit_user_registration_path
    assert_response :success
    patch user_registration_path, params: {
      user: {
        name: "Updated Name",
        email: users(:one).email,
        zone: "South Denver",
        can_host: "0",
        current_password: "password123"
      }
    }
    assert_redirected_to root_path
    users(:one).reload
    assert_equal "Updated Name", users(:one).name
    assert_equal "South Denver", users(:one).zone
    assert_not users(:one).can_host?
  end
end
