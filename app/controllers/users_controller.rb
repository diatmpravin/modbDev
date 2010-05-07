class UsersController < ApplicationController

  require_role User::Role::USERS, :except => [:forgot_password, :reset_password, :set_password]
  before_filter :new_user,     :only => [:new, :create]
  before_filter :set_user,     :only => [:edit, :update, :destroy]
  before_filter :set_users,    :only => :index
  before_filter :filter_roles, :only => [:create, :update]
  before_filter :filter_self,  :only => [:edit, :update, :destroy]
  
  skip_before_filter :login_required, :only => [:forgot_password, :reset_password, :set_password]
  
  layout except_ajax('users')

  def index
    respond_to do |format|
      format.html {
        if request.xhr?
          render :partial => "tree", :locals => {:node => current_user.device_group_or_root}
        else
          redirect_to dashboard_path(:anchor => 'users')
        end
      }
      format.json {
        render :json => @users.to_json(index_json_options)
      }
    end
  end
  
  def new
  end
  
  def create
    if @user.update_attributes(params[:user])
      #flash?
      #flash[:notice] = "User '#{@user.login}' has been created. A welcome email was sent to '#{@user.email}'."
      render :json => {
        :status => 'success'
      }
    else
      render :json => {
        :status => 'failure',
        :html => render_to_string(:partial => 'form', :locals => {:user => @user})
      }
    end
  end
  
  def edit
  end
  
  def update
    if params[:user][:device_group_id] == '0'
      # Root
      params[:user][:device_group_id] = nil
    end
    
    params[:user][:roles] ||= []

    if @user.update_attributes(params[:user])
      render :json => {
        :status => 'success'
      }
    else
      render :json => {
        :status => 'failure',
        :html => render_to_string(:partial => 'form', :locals => {:user => @user})
      }
    end
  end
  
  def destroy
    @user.destroy
    
    render :json => {
      :status => 'success',
      :html => 'This space intentionally left blank.'
    }
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
    unless @user = User.find_by_password_reset_code(params[:id])
      flash[:error] = 'The set password link you followed is no longer valid.'
      redirect_to forgot_password_path
      return
    end
    
    unless request.post?
      render :action => 'set_password', :layout => 'external'
      return
    end
    
    @user.reset_password(params[:password], params[:password_confirmation])
    
    if @user.save
      self.current_user = @user.reload
      
      flash.now[:notice] = "Welcome, #{@user.name}!"
      redirect_to root_path
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
    
    @user.reset_password(params[:password], params[:password_confirmation])
    
    if @user.save
      self.current_user = @user.reload
      
      flash.now[:notice] = 'Your password has been updated.'
      redirect_to root_path
    else
      render :action => 'reset_password', :layout => 'external'
    end
  end
  
  protected
 
  def new_user
    @user = current_account.users.new
  end
  
  def set_user
    @user = current_account.users.find(params[:id])
  end
  
  def set_users
    #@users = search_on User do
    #  current_account.users.paginate :page => params[:page], :per_page => 30
    #end

    #@users should be all the users @user can access (all users in current_user.device_group.users)
    #@users = current_account.users.find(:all, :conditions => [ "id <> ?", current_user.id ])
    @users = current_account.users
  end
  
  # Prevent the current user from assigning roles they aren't allowed to
  def filter_roles
    if params[:user] && params[:user][:roles]
      params[:user][:roles] = params[:user][:roles].map(&:to_i) & current_user.assignable_roles
    end
  end

  # Prevent the current user from editing his/herself
  def filter_self
    if @user && !current_user.can_edit?(@user)
      respond_to do |format|
        format.html {
          render :nothing => true, :status => 403
        }
        format.json {
          render :json => {:status => 'failure'}, :status => 403
        }
      end
    end
  end

  def index_json_options
    {:only => [:id, :name, :device_group]}
  end
end
