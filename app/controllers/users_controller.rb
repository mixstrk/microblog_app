require "pry"
require "slack"

class UsersController < ApplicationController

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)   
    if @user.save
      client = Slack::Web::Client.new
      client.chat_postMessage(channel: '#test-bot-message', blocks: block_register(@user))
      reset_session
      log_in @user
      flash[:success] = "Welcome to the Gimbarr!"
      redirect_to @user
    else
      render 'new', status: :unprocessable_entity
    end
  end

  private

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

  
  def user_params
    params.require(:user).permit(:name, :email, :password,
                                 :password_confirmation)
  end
end
