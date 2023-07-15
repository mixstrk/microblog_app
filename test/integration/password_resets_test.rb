require "test_helper"

class PasswordResets < ActionDispatch::IntegrationTest
  
  def setup
    ActionMailer::Base.deliveries.clear
    @user = users(:maxim)
  end
end

class ForgotPasswordFormTest < PasswordResets

  test "password reset path" do
    get new_password_reset_path
    assert_template "password_resets/new"
    assert_select "input[name=?]", "password_reset[email]"
  end

  test "reset path with invalid email" do
    post password_resets_path, params: { password_reset: { email: "" } }
    assert_response :unprocessable_entity
    assert_not flash.empty?
    assert_template "password_resets/new"
  end
end

class PasswordResetForm < PasswordResets

  def setup
    super
    @user = users(:maxim)
    post password_resets_path,
         params: { password_reset: { email: @user.email } }
    @reset_user = assigns(:user)
  end
end

class PasswordFormTest < PasswordResetForm

  test "reset with valid email" do
    assert_not_equal @user.reset_digest, @reset_user.reset_digest
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_not flash.empty?
    assert_redirected_to root_path
  end

  test "reset with wrong email" do
    get edit_password_reset_path(@reset_user.reset_token, email: "")
    assert_redirected_to root_path
  end

  test "reset with inactive user" do
    @reset_user.toggle!(:activated)
    get edit_password_reset_path(@reset_user.reset_token, 
                                 email: @reset_user.email)
    assert_redirected_to root_path
  end

  test "reset with right email but wrong token" do
    get edit_password_reset_path("wrong token",
                                 email: @reset_user.email)
    assert_redirected_to root_path
  end

  test "reset with right email and right token" do
    get edit_password_reset_path(@reset_user.reset_token,
                                 email: @reset_user.email)
    assert_template "password_resets/edit"
    assert_select "input[name=email][type=hidden][value=?]",
      @reset_user.email
  end
end

class PaswordUpdateTest < PasswordResetForm

  test "update with invalid password and confirmation" do
    patch password_reset_path(@reset_user.reset_token),
          params: {
            email: @reset_user.email,
            user: {
              password:              "gimbarr",
              password_confirmation: "rrabmig" } }
    assert_select "div#error_explanation"
    error_message = "Password confirmation doesn't match Password"
    assert_select "ul" do
      assert_select "li", error_message
    end
  end

  test "update with empty password" do
    patch password_reset_path(@reset_user.reset_token),
    params: {
      email: @reset_user.email,
      user: {
        password:              "",
        password_confirmation: "" } }
    assert_select "div#error_explanation"
    error_message = "Password can't be empty"
    assert_select "ul" do
      assert_select "li", error_message
    end
  end

  test "update with short password" do
    patch password_reset_path(@reset_user.reset_token),
          params: {
            email: @reset_user.email,
            user: {
              password:              "12345",
              password_confirmation: "12345" } }
    assert_select "div#error_explanation"
    error_message = "Password is too short (minimum is 6 characters)"
    assert_select "ul" do
      assert_select "li", error_message
    end
  end

  test "valid password with confirmation" do
    patch password_reset_path(@reset_user.reset_token),
          params: {
            email: @reset_user.email,
            user: {
              password:              "gimbarr",
              password_confirmation: "gimbarr" } }
    assert_redirected_to @reset_user
  end
end

class ExpiredToken < PasswordResets

  def setup
    super
    # Create a password-reset token.
    post password_resets_path,
         params: { password_reset: { email: @user.email } }
    @reset_user = assigns(:user)
    # Expire the token by hand.
    @reset_user.update_attribute(:reset_sent_at, 3.hours.ago)
    # Attempt to update the user's password.
    patch password_reset_path(@reset_user.reset_token), 
          params: {
            email: @reset_user.email,
            user: {
              password:              "gimbarr",
              password_confirmation: "gimbarr" } }
  end
end

class ExpiredTokenTest < ExpiredToken

  test "should redirect to the password-reset page" do
    assert_redirected_to new_password_reset_url
  end

  test "should include the word 'expired' on the password-reset page" do
    follow_redirect!
    assert_match "Password reset has expired.", response.body
  end
end