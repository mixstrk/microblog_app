require "test_helper"

class UsersShowTest < ActionDispatch::IntegrationTest
  
  def setup
    @inactive_user = users(:inactive)
    @activated_user = users(:oleg)
  end

  test "should redirect when user not actived" do
    get user_path(@inactive_user)
    assert_response :redirect
    assert_redirected_to root_path
  end

  test "should display user when activated" do
    get user_path(@activated_user)
    assert_response :success
    assert_template 'users/show'
  end
end
