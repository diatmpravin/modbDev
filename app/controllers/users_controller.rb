class UsersController < ApplicationController
  before_filter :require_role, :except => [:forgot_password, :reset_password, :set_password]
  before_filter :new_user,     :only => [:new, :create]
  before_filter :set_user,     :only => [:edit, :update, :destroy]
  before_filter :set_users,    :only => :index
  before_filter :filter_roles, :only => [:create, :update]
  
  skip_before_filter :login_required, :only => [:forgot_password, :reset_password, :set_password]
  
  layout except_ajax('users')
  
  def index
  end
  
  def new
  end
  
  def create
    if @user.update_attributes(params[:user])
      flash[:notice] = "User '#{@user.login}' has been created. A welcome email was sent to '#{@user.email}'."
      redirect_to :action => 'index'
    else
      render :action => 'new'
    end
  end
  
  def edit
  end
  
  def update
    if @user.update_attributes(params[:user])
      redirect_to :action => 'index'
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @user.destroy
    
    redirect_to :action => 'index'
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
  
  def set_password
    unless @user = User.find_by_activation_code(params[:id])
      flash[:error] = 'The set password link you followed is no longer valid.'
      redirect_to forgot_password_path #somewhere else that is appropriate
      return
    end
    
    unless request.post?
      render :action => 'set_password', :layout => 'external'
      return
    end
    
    @user.set_password(params[:password], params[:password_confirmation])
    
    if @user.save
      @user.password = nil
      @user.password_confirmation = nil
      @user.activate
      
      flash[:notice] = 'Your password has been set.'
      redirect_to login_path #somewhere else that is appropriate
    else
      render :action => 'set_password', :layout => 'external'
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
    
    @user.set_password(params[:password], params[:password_confirmation])
    
    if @user.save
      flash[:notice] = 'Your password has been updated.'
      redirect_to login_path
    else
      render :action => 'reset_password', :layout => 'external'
    end
  end
  
  protected
  def require_role
    redirect_to root_path unless current_user.has_role?(User::Role::USERS)
  end
  
  def new_user
    @user = current_account.users.new
  end
  
  def set_user
    @user = current_account.users.find(params[:id])
  end
  
  def set_users
    @users = search_on User do
      current_account.users.paginate :page => params[:page], :per_page => 30
    end
  end
  
  # Prevent the current user from assigning roles they aren't allowed to
  def filter_roles
    if params[:user] && params[:user][:roles]
      params[:user][:roles] = params[:user][:roles].map(&:to_i) & current_user.assignable_roles
    end
  end
end
