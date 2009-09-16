class SessionsController < ApplicationController
  skip_before_filter :login_required, :only => [:new, :create]
  
  layout 'external'
  
  def new
  end
  
  def create
    account = Account.find_by_number(params[:account_number])
    if account
      self.current_user = User.authenticate(account, params[:login], params[:password])
      
      if logged_in?
        if self.current_user.activated?
          if params[:remember_me] == "1"
            current_user.remember_me unless current_user.remember_token?
            cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
          end
          
          default = maps_path
          
          flash.discard
          redirect_back_or_default(default)
        else
          @email = self.current_user.email
          render :action => 'waiting_on_activation', :layout => 'wizard'
        end
      else
        flash.now[:error] = 'Your Username or Password is incorrect.'
        render :action => 'new'
      end
    else
      flash.now[:error] = 'Your Account ID is incorrect.'
      render :action => 'new'
    end
  end

  def destroy
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash.now[:notice] = "You have been logged out."
    redirect_to login_path
  end
end