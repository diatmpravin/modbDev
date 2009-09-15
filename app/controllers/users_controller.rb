class UsersController < ApplicationController
  before_filter :set_user, :only => [:edit, :update, :destroy, :show]
  before_filter :set_users, :except => [:show, :destroy]
  
  layout except_ajax('users')
  
  def index
    @user = current_user.users.new
  end
  
  def new
    @user = current_user.users.new
  end
  
  def create
    @user = current_user.users.build(params[:user].first)
    @user.account = current_account
    
    @user.password = 'password'
    @user.password_confirmation = 'password'
    @user.activated_at = Time.now
    
    if @user.save
      render :json => {:status => 'success'}
    else
      render :json => {
        :status => 'failure',
        :html => render_to_string(:action => 'new')
      }
    end
  end
  
  def show
  end
  
  def edit
  end
  
  def update
    if @user.update_attributes(params[:user][@user.id.to_s])
      render :json => {:status => 'success'}
    else
      render :json => {
        :status => 'failure',
        :html => render_to_string(:action => 'edit')
      }
    end
  end
  
  def destroy
    @user.destroy
    
    render :json => {:status => 'success'}
  end
  
  protected
  def set_user
    @user = current_user.users.find(params[:id])
  end
  
  def set_users
    @users = current_user.users
  end
end