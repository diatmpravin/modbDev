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

  def activation(account)
    recipients account.email
    from support_address
    body :url => url_for(:controller => 'accounts', :action => 'activate', :id => account.activation_code)
    subject 'Fleet: Account Activation'
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
  
  private
  def support_address
    'support@fleet.gomoshi.com'
  end
  
  def alerts_address
    'alerts@fleet.gomoshi.com'
  end
end
