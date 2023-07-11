require "pry"
require "slack"

class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: :destroy

  def index 
    @users = User.where(activated: true).paginate(page: params[:page])
  end

  def show
    # begin
      @user = User.find(params[:id])
      redirect_to root_url and return unless @user.activated?
    # rescue ActiveRecord::RecordNotFound
      # redirect_to user_not_found_url
    # end
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)   
    if @user.save
      @user.send_activation_email
      flash[:info] = "Please check your email to activate your account."
      redirect_to root_path
      # client = Slack::Web::Client.new
      # client.chat_postMessage(channel: '#test-bot-message', blocks: block_register(@user))
      # reset_session
      # log_in @user
      # flash[:success] = "Welcome to the Gimbarr!"
      # redirect_to @user
    else
      render 'new', status: :unprocessable_entity
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render 'edit', status: :unprocessable_entity
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted"
    redirect_to users_url, status: :see_other
    
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password,
                                 :password_confirmation, :admin)
  end

  # Before filters

  # Confirms a logged-in user
  def logged_in_user
    unless logged_in?
      store_location
      flash[:danger] = "Please log in."
      redirect_to login_url, status: :see_other
    end
  end

  # Confirms the correct user.
  def correct_user
    begin
      @user = User.find(params[:id])
      redirect_to(root_path, status: :see_other) unless current_user?(@user)
    rescue
      redirect_to user_not_found_url
    end
  end

  # Confirms an admin user.
  def admin_user
    redirect_to(root_url, status: :see_other) unless current_user.admin
  end

  # Block for send a message to slack when a user sign up

  def block_register(user)
    [
      {
        "type": "section",
        "text": {
          "type": "mrkdwn",
          "text": 
          <<~TEXT
              :white_check_mark: <http://127.0.0.1:3000/users/#{user.id}|User> registered
              *email*: #{@user.email}
              *name*: #{@user.name}
            TEXT
        }
      },
      {
        "type": "actions",
        "elements": [
          {
            "type": "button",
            "text": {
              "type": "plain_text",
              "text": "Delete user",
              "emoji": true
            },
            "style": "danger",
            "value": "click_me_to_bun",
            "action_id": "delete_button_click"
          }
        ]
      }
	  ]
  end
end
