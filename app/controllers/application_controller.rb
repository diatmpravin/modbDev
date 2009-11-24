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

  def filter_query
    session[:filter] ? session[:filter][:full] : ""
  end
  helper_method :filter_query
  
  protected

  SPHINX_WARNING = "Filtering is currently unavailable. " + 
                   "We have been informed of this problem and will have it fixed soon."

  # Perform a Sphinx search on the given class.
  # Filter is set by FiltersController.
  # The block is the default to return if a search fails
  # or if no search parameters are given.
  #
  # See DevicesController#set_device for a usage example.
  def search_on(klass, &default)
    if session[:filter] && session[:filter].any?
      begin
        filter = session[:filter].dup

        filter.delete(:full)
        query = filter.delete(:query)
        conditions = filter

        return klass.search(query, :conditions => conditions,
                            :with => {:account_id => current_account.id}, :mode => :extended)
      rescue => ex
        flash[:warning] = SPHINX_WARNING
        Mailer.deliver_exception_thrown(ex, "Sphinx Search Error")
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
