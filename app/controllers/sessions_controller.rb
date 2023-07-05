require 'pry'

class SessionsController < ApplicationController
  def new
    if logged_in?
      redirect_to root_path, status: :see_other
    end
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      forwarding_url = session[:forwarding_url]
      # binding.pry
      reset_session
      remember user
      log_in user
      redirect_to forwarding_url || user
      
      # Log the user in and redirect to the user's show page.
    else
      # Create an error message
      flash.now[:danger] = 'Invalid email/password combination'
    render 'new', status: :unprocessable_entity
    end
  end

  # def show
    
  #     user = User.find_by(email: params[:session][:email].downcase)
    
  # end

  def destroy
    log_out
    redirect_to root_url, status: :see_other
  end
end
