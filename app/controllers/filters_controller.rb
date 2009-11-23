class FiltersController < ApplicationController

  def create
    session[:filter] = FilterQuery.parse(params[:query])
    redirect_to params[:return_to] || root_path
  end

  def destroy
    session[:filter] = nil
    redirect_to params[:return_to] || root_path
  end

end
