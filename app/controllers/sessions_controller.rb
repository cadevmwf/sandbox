class SessionsController < ApplicationController
  def create
    if (user = User.find_by_email(params[:email])) && user.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to user, :notice => "Sign-in successful."
    else
      redirect_to root_url, :notice => "Sign-in unsuccessful."
    end
  end
  
  def destroy
    reset_session
    redirect_to root_url
  end
end