require 'open-uri'

class UsersController < ApplicationController
  before_filter :require_login, :only => [:show, :edit, :update, :delete]
  
  def require_login
    if session[:user_id] && session[:user_id] == params[:id].to_i
      @user = current_user   
    else
      redirect_to root_url, :notice => "Not authorized for that."
    end
  end
  
  def root
    if logged_in?
      @user = current_user
      render 'show'
    else
      @users = User.all
      render 'index'
    end
  end
  
  def authorize
    @code = params[:code]
    
    uri = "https://graph.facebook.com/oauth/access_token?client_id=434825803222733&redirect_uri=http://localhost:3000/auth&client_secret=ac5251e1281670a5edec924f33a61cc7&code=#{@code}"
    
    @response = open(uri).read
    
    access_token = @response.split('&').first.split('=').last
    
    user = User.find_by_id(session[:user_id])
    user.facebook_access_token = access_token
    user.save
    
    redirect_to user_url(user)
    
  end

  def index
    @users = User.all
  end

  def show
  end

  def new
    @user = User.new
  end

  def edit
  end

  def create
    @user = User.new(params[:user])

    if @user.save
      session[:user_id] = @user.id
      redirect_to @user, notice: 'Sign-up successful.'
    else
      render 'new'
    end
  end

  def update
    if @user.update_attributes(params[:user])
      redirect_to @user, notice: 'Update successful.'
    else
      render 'edit'
    end
  end

  def destroy
    @user.destroy

    redirect_to users_url
  end
end
