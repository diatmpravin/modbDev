class ProfileController < ApplicationController

  layout except_ajax('profile')

  # GET /profile
  def show
    @user = current_user
  end

  # PUT /profile
  def update
    @user = current_user
    if @user.update_attributes(params[:user])
      flash[:notice] = "Profile settings updated."

      redirect_to profile_path
    else
      flash[:error] = "Unable to update Profile. Please fix errors below."

      render :action => "show"
    end
  end

end
