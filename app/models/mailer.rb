class Mailer < ActionMailer::Base
  layout nil
  
  #
  # Account
  #
  def forgotten_login(email, accounts)
    recipients email
    from support_address
    body :accounts => accounts
    subject 'Mobd Forgotten Login'
    content_type "text/html"
  end
  
  def forgotten_password(account)
    recipients account.email
    from support_address
    body :url => url_for(:controller => 'accounts', :action => 'reset_password', :id => account.password_reset_code)
    subject 'Mobd Forgotten Password'
    content_type "text/html"
  end

  def account_cancelled(account)
    recipients  account.email
    from        support_address
    subject     "MOBD: Account Cancelled"
    body        :account => account
    content_type "text/html"
  end

  def activation(account)
    recipients account.email
    from support_address
    body :url => url_for(:controller => 'accounts', :action => 'activate', :id => account.activation_code)
    subject "MOBD: Account Activation"
    content_type "text/html"
  end
  
  #
  # Alerts
  #
  def email_alert(address, message)
    recipients address
    from alerts_address
    body :message => message
    subject 'Mobd Alert'
  end
  
  private
  def support_address
    'support@mobd.gomoshi.com'
  end
  
  def alerts_address
    'alerts@mobd.gomoshi.com'
  end
end
