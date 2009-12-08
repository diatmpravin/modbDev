class FiltersController < ApplicationController

  def create
    session[:filter] ||= {}
    session[:filter][params[:class]] = 
      if params[:query] && params[:query].any?
        FilterQuery.parse(params[:query])
      else 
        nil
      end

    logger.info "Session: #{session.inspect}"

    redirect_to params[:return_to] || root_path
  end

  def destroy
    if session[:filter] && session[:filter].any?
      session[:filter][params[:class]] = nil
    end

    redirect_to params[:return_to] || root_path
  end

end
