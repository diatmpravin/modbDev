class DispatchController < ApplicationController
  skip_before_filter :login_required
  
  protect_from_forgery :except => [:index]
  
  # Web front-end for Dispatch controllers
  def index
    render :json => Dispatch::Controller.dispatch(params[:msg])
  end
end