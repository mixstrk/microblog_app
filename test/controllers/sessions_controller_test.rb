require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "should get new when not logget in" do
    get login_path
    assert_response :success
    assert_select "title", "Log in | Gimbarr"
  end

  test "should redirect when logged_in" do
    log_in_as(users(:maxim))
    assert is_logged_in?
    get login_path
    assert_response :see_other
    assert_redirected_to root_path
  end
end
