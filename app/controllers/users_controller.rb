class UsersController < ApplicationController
  before_filter :require_login, :only => [:show, :edit, :update, :delete]
  
  def require_login
    if session[:user_id] && session[:user_id] == params[:id].to_i
      @user = User.find(params[:id])      
    else
      redirect_to root_url, :notice => "Not authorized for that."
    end
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
    @user = User.find(params[:id])
    @user.destroy

    redirect_to users_url
  end
end
