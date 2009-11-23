class FiltersController < ApplicationController

  def create
    session[:filter] = 
      if params[:query] && params[:query].any?
        FilterQuery.parse(params[:query])
      else 
        nil
      end

    redirect_to params[:return_to] || root_path
  end

  def destroy
    session[:filter] = nil
    redirect_to params[:return_to] || root_path
  end

end
