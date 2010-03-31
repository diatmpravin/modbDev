class Device < ActiveRecord::Base

  def alert_recipient_ids=(list)
    self.alert_recipients = account.alert_recipients.find(
      list.reject {|a| a.blank?}
    )
  end
  
  def send_alert(message, at = nil)
    at = (at || Time.now).in_time_zone(self.zone)
    self.alert_recipients.each do |r|
      r.alert(message, at)
    end
  end
  
end
