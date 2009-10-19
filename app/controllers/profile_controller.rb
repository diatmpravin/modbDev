class ProfileController < ApplicationController

  layout except_ajax('profile')

  # GET /profile
  def show
    @user = current_user
  end

  # PUT /profile
  def update
    @user = current_user
    @user.update_attributes(params[:user])

    redirect_to profile_path
  end

end
