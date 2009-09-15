class AccountsController < ApplicationController
  skip_before_filter :login_required, :only => [:new, :create, :activate]
  
  before_filter :set_account, :only => [:edit, :update]
  before_filter :require_password, :only => [:destroy]
  
  layout :external_or_accounts
  
  def new
  end
  
  def create
    cookies.delete :auth_token
    
    @account = Account.new(params[:account])
    if @account.save
      @account.send_activation_email
      render :action => 'account_created'
    else
      render :action => 'new'
    end
  end
  
  def edit
    @subscription = @account.subscription
  end
  
  def update
    if @account.update_attributes(params[:account])
      @account = Account.find(current_account.id)
      flash.now[:notice] = 'Settings saved.'
      render :action => 'edit'
    else
      flash.now[:error] = 'Please correct the errors below.'
      render :action => 'edit'
    end
  end
  
  def destroy
    Mailer.deliver_account_cancelled(current_account)
    current_account.destroy
    current_account = nil
    render :json => {:status => 'success'}
  end
  
  def resend_activation
    @account = current_account
    @account.send_activation_email
    reset_session
  end
  
  def activate
    a = Account.find_by_activation_code(params[:id])
    
    if a
      a.activate
      flash[:notice] = 'Congratulations, your account has been activated! Please login to setup your account.'
    end
    
    redirect_to login_path
  end
  
  protected
  def set_account
    @account = current_account
  end
  
  def require_password
    unless current_account.authenticated?(params[:password])
      respond_to do |format|
        format.html {
          flash[:error] = 'You must enter your current password.'
          redirect_to :action => 'edit'
        }
        format.json {
          render :json => {
            :status => 'failure',
            :error => 'You must enter your current password.'
          }
        }
      end
    end
  end
  
  def external_or_accounts
    if %w{new create resend_activation activate}.include? params[:action]
      'external'
    else
      'accounts'
    end
  end
end
