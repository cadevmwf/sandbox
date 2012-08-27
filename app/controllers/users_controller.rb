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
    
    access_token = CGI::parse(@response)["access_token"].first
    
    current_user.facebook_access_token = access_token
    logger.debug '============================='
    logger.debug current_user.inspect
    me_url = "https://graph.facebook.com/me?access_token=#{access_token}"
    
    me_response = JSON.parse(open(me_url).read)
    
    current_user.facebook_id = me_response["id"]
    current_user.name = me_response["name"]
    if me_response["location"].present? && me_response["location"]["name"].present?
      current_user.location = me_response["location"]["name"]
    end
    
    current_user.save
    
    redirect_to user_url(current_user)
  end

  def index
    @users = User.all
  end
  
  def pull_friends
    
    current_user.friends.destroy_all
  
    url = "https://graph.facebook.com/me/friends?fields=name,id,location&access_token=#{current_user.facebook_access_token}"

    response = open(url).read

    @friends = JSON.parse(response)["data"]
    
    @friends.each do |friend_hash|
      if friend_hash["name"].present? && friend_hash["location"].present? && friend_hash["location"]["name"].present?
        f = Friend.new
        f.user_id = current_user.id
        f.name = friend_hash["name"]
        f.facebook_id = friend_hash["id"]
        f.location = friend_hash["location"]["name"]
        f.save
      end
    end
    redirect_to current_user
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
