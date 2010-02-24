class AccountsController < ApplicationController
  before_filter :require_reseller
  before_filter :require_role
  before_filter :set_account, :only => [:edit, :update]
  before_filter :set_accounts, :only => :index
  before_filter :require_password, :only => [:destroy]
  
  layout 'accounts'
  
  def index
    @account = current_account
  end
  
  def new
    @account = current_account.children.new
    @account.users.build
  end
  
  def create
    @account = current_account.children.new

    if @account.update_attributes(params[:account])
      flash[:notice] = "Account #{@account.number} has been created. A welcome email was sent to the admin user."
      redirect_to :action => 'index'
    else
      render :action => 'new'
    end
  end
  
  def edit
  end
  
  def update
    if @account.update_attributes(params[:account])
      redirect_to :action => 'index'
    else
      render :action => 'edit'
    end
  end

  protected
  
  def set_account
    @account = current_account.children.find(params[:id])
  end
  
  def set_accounts
    @accounts = search_on Account do
      current_account.children.paginate :page => params[:page], :per_page => 30
    end
  end
  
  def require_reseller
    # Is it better to have all these guys return 403 Forbidden?
    redirect_to root_path unless current_account.reseller?
  end
  
  def require_role
    # Is it better to have all these guys return 403 Forbidden?
    redirect_to root_path unless current_user.has_role?(User::Role::RESELLER)
  end
  
  def external_or_accounts
    if %w{new create resend_activation activate}.include? params[:action]
      'external'
    else
      'accounts'
    end
  end
end
