class Mailer < ActionMailer::Base
  layout nil
  
  #
  # Account
  #
  def forgotten_password(user)
    recipients user.email
    from support_address
    body :url => reset_password_url(:id => user.password_reset_code)
    subject 'Fleet: Forgotten Password'
    content_type 'text/html'
  end
  
  #
  # Alerts
  #
  def email_alert(address, message)
    recipients address
    from alerts_address
    body :message => message
    subject 'Fleet Alert'
  end

  def exception_thrown(exception, message = "")
    from "error@gomoshi.com"
    recipients %w(dev@crayoninterface.com)
    subject "[Fleet #{Rails.env.capitalize}] Exception Thrown"
    body :exception => exception, :message => message
  end
  
  private
  def support_address
    'support@fleet.gomoshi.com'
  end
  
  def alerts_address
    'alerts@fleet.gomoshi.com'
  end
end
