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
  
  def set_password(user, sub, message)
    recipients user.email
    from support_address
    body(:url => set_password_url(:id => user.activation_code), :message => message)
    subject sub
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

  def contact_us(user, sub, message)
    recipients support_address
    from user.email
    body(:message => message, :user => user)
    subject("Contact Page: #{sub}")
  end

  def contact_us_confirmation(user, sub, message)
    recipients user.email
    from support_address
    body(:message => message)
    subject("Contact Confirmation: #{sub}")
  end
  
  private
  def support_address
    'support@fleet.gomoshi.com'
  end
  
  def alerts_address
    'alerts@fleet.gomoshi.com'
  end
end
