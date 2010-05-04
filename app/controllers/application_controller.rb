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

  # Multi-purpose record-not-found rescue logic
  rescue_from(ActiveRecord::RecordNotFound) do |error|
    if request.format == Mime::JSON
      render :json => {
        :status => 'failure',
        :error => 'Unable to perform the requested action.'
      }
    else
      redirect_to :action => 'index'
    end
  end

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
        flash.now[:warning] = SPHINX_WARNING
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

  # complicated role checking
  class << self
    def require_role(roles, options = {})

      self.instance_variable_set '@required_roles', roles.is_a?(Array) ? roles : [roles]

      before_filter :require_role, options
    end

    alias require_roles require_role
  end  

  def require_role
    roles = self.class.instance_variable_get '@required_roles'

    roles.each do |role|
      unless current_user.has_role?(role)
        respond_to do |format|
          format.html {
            render :nothing => true, :status => 403
          }
          format.json {
            render :json => {:status => 'failure'}, :status => 403
          }
        end
        return
      end
    end
  end
 
end
