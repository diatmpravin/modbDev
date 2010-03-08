class Device < ActiveRecord::Base

  def alert_recipient_ids=(list)
    self.alert_recipients = account.alert_recipients.find(
      list.reject {|a| a.blank?}
    )
  end
  
  def send_alert(message, at = nil)
    self.alert_recipients.each do |r|
      r.alert(message, at || self.zone.now)
    end
  end
  
end
