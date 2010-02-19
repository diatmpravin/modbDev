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

  # Any record-not-found will redirect back to :index
  # If other logic is required, implement in the appropriate
  # controller
  #rescue_from(ActiveRecord::RecordNotFound) do |error|
  #  redirect_to :action => "index"
  #end

  def filter_query
    logger.info "(Filter Query) Session: #{session.inspect}"

    if session[:filter] && session[:filter][self.filter_class]
      session[:filter][self.filter_class][:full]
    else
      ""
    end
  end
  helper_method :filter_query

  def filter_class
    @filter_class
  end
  helper_method :filter_class
  
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
    class_name = klass.to_s
    
    # Expose this class to the views
    @filter_class = class_name

    if session[:filter] && session[:filter][class_name] && session[:filter][class_name].any?
      begin
        filter = session[:filter][class_name].dup

        filter.delete(:full)
        query = filter.delete(:query)
        conditions = filter

        query = klass.search(query, :conditions => conditions,
                  :with => {:account_id => current_account.id}, 
                  :page => params[:page], :per_page => 30,
                  :mode => :extended)

        # Force the search to happen here so we can catch
        # any errors that might get thrown
        query.results

        return query
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
