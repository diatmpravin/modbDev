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
  def phone_software_path
    if Rails.env.production?
      'http://dl.gomoshi.com/mobd'
    else
      'http://dlqa.gomoshi.com/mobd'
    end
  end
end
