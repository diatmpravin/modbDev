class FiltersController < ApplicationController
  def create
    session[:filter] = params[:query]

    render :nothing => true
  end

  def destroy
    session[:filter] = nil

    render :nothing => true
  end
end
