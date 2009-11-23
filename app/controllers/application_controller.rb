class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  include ExceptAjax
  include ExceptionNotifiable
  
  before_filter :login_required
  
  layout except_ajax('internal')
  
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  protect_from_forgery
  
  # See ActionController::Base for details 
  filter_parameter_logging :password
  
  protected

  # Perform a Sphinx search on the given class.
  # Filter is set by FiltersController.
  # The block is the default to return if a search fails
  # or if no search parameters are given.
  #
  # See DevicesController#set_device for a usage example.
  def search_on(klass, &default)
    if session[:filter] && session[:filter].any?
      if ThinkingSphinx.sphinx_running?
        return klass.search session[:filter], :with => {:account_id => current_account.id}, :mode => :extended
      else
        flash[:warning] = "Filtering is currently unavailable. " + 
                          "We have been informed of this problem and will have it fixed soon."
        # TODO Send out an error to dev to inform of failure
      end
    end

    # Fall-through: just return the value of the defaults block
    default.call
  end

  def phone_software_path
    if Rails.env.production?
      'http://dl.gomoshi.com/mobd'
    else
      'http://dlqa.gomoshi.com/mobd'
    end
  end
end
