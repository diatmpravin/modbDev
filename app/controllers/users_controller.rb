class UsersController < ApplicationController
  before_filter :set_user, :only => [:edit, :update, :destroy, :show]
  before_filter :set_users, :except => [:show, :destroy, :forgot_password, :reset_password]
  
  skip_before_filter :login_required, :only => [:forgot_password, :reset_password]
  
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
  
  def forgot_password
    unless request.post?
      render :action => 'forgot_password', :layout => 'external'
      return
    end
    
    account = Account.find_by_number(params[:account_number])
    if account
      user = account.users.find_by_login(params[:login])
      
      if user
        user.forgot_password
        flash[:notice] = 'You have been sent an email with instructions on how to reset your password.'
        redirect_to login_path
      else
        flash.now[:error] = 'Your Account ID or Username is incorrect.'
        render :action => 'forgot_password', :layout => 'external'
      end
    else
      flash.now[:error] = 'Your Account ID or Username is incorrect.'
      render :action => 'forgot_password', :layout => 'external'
    end
  end
  
  def reset_password 
    unless @user = User.find_by_password_reset_code(params[:id])
      flash[:error] = 'The password reset link you followed is no longer valid.'
      redirect_to forgot_password_path
      return
    end
    
    unless request.post?
      render :action => 'reset_password', :layout => 'external'
      return
    end
    
    @user.crypted_password = nil
    @user.password_reset_code = nil
    @user.password = params[:password]
    @user.password_confirmation = params[:password_confirmation]
    
    if @user.save
      flash[:notice] = 'Your password has been updated.'
      redirect_to login_path
    else
      render :action => 'reset_password', :layout => 'external'
    end
  end
  
  protected
  def set_user
    @user = current_user.users.find(params[:id])
  end
  
  def set_users
    @users = current_user.users
  end
end