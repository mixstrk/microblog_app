require "test_helper"

class UsersIndex < ActionDispatch::IntegrationTest
  
  def setup
    @admin = users(:maxim)
    @non_admin = users(:oleg)
  end
end

  # test "index as admin including pagination and delete links" do


  # DElete this lines
  #   log_in_as(@admin)
  #   get users_path
  #   assert_template "users/index"
  #   assert_select "div.pagination"



  #   first_page_of_users = User.paginate(page: 1)
  #   first_page_of_users.each do |user|
  #     assert_select "a[href=?]", user_path(user), 
  #                                text: user.name
  #     unless user == @admin
  #       assert_select "a[href=?]", user_path(user), 
  #                                   text: "delete"
  #     end
  #   end
  #   assert_difference "User.count", -1 do
  #     delete user_path(@non_admin)
  #     assert_response :see_other
  #     assert_redirected_to users_url
  #   end
  # end

  # test "index as non-admin" do
  #   log_in_as(@non_admin)
  #   get users_path
  #   assert_select "a", text: "delete", count: 0
  # end


class UsersIndexAdmin < UsersIndex

  def setup
    super
    log_in_as(@admin)
    get users_path
  end
end

class UsersIndexAdminTest < UsersIndexAdmin

  test "should render the index page" do
    assert_template "users/index"
  end

  test "should paginate users" do
    assert_select "div.pagination"
  end

  test "should have delete links" do
    first_page_of_users = User.where(activated: true).paginate(page: 1)
    first_page_of_users.each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
      unless user == @admin
        assert_select 'a[href=?]', user_path(user), text: 'delete'
      end
    end
  end

  test "should be able to delete non-admin user" do
    assert_difference "User.count", -1 do
      delete user_path(@non_admin)
    end
    assert_response :see_other
    assert_redirected_to users_url
  end

  test "should display only activated users" do
    User.paginate(page: 1).first.toggle!(:activated)
    get users_path
    assigns(:users).each do |user|
      assert user.activated?
    end
  end
end

class UserNonAdminIndexTest < UsersIndex
  test "should not have delete links as non-admin" do
    log_in_as(@non_admin)
    get users_path
    assert_select "a", text: "delete", count: 0
  end
end
