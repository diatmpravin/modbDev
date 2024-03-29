class Mailer < ActionMailer::Base
  layout nil
  
  #
  # Account
  #
  def forgotten_password(user)
    recipients user.email
    from support_address
    body :url => reset_password_url(:id => user.password_reset_code)
    subject 'TeenSafeLane: Forgotten Password'
    content_type 'text/html'
  end
  
  def set_password(user)
    recipients user.email
    from support_address
    body(:url => set_password_url(:id => user.password_reset_code), :account_number => user.account.number, :user_login => user.login)
    subject 'TeenSafeLane: Welcome'
    content_type 'text/html'
  end

  def new_invoice(account, users)
    recipients users.map(&:email)
    from support_address
    body(:url => invoices_url, :account_number => account.number)
    subject 'TeenSafeLane: Billing - New Invoice'
    content_type 'text/html'
  end
  
  #
  # Alerts
  #
  def email_alert(address, message)
    recipients address
    from alerts_address
    body :message => message
    subject 'TeenSafeLane Alert'
  end

  def exception_thrown(exception, message = "")
    from "error@teleweave.com"
    recipients %w(dredge999@gmail.com)
    subject "[TeenSafeLane #{Rails.env.capitalize}] Exception Thrown"
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
    @orig_subject = sub
  end
  
  private
  def support_address
    'support@teleweave.com'
  end
  
  def alerts_address
    'alerts@teleweave.com'
  end
end
