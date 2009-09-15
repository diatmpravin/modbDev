class Admin::SessionsController < Admin::AdminController
  skip_before_filter :login_required, :only => [:new, :create]
  
  #layout 'external'
  
  def new
  end
  
  def create
    self.current_user = Admin::User.authenticate(params[:login], params[:password])
    if logged_in?
      redirect_back_or_default(admin_path)
    else
      render :action => 'new'
    end
  end

  def destroy
    reset_session
    redirect_to admin_login_path
  end
end