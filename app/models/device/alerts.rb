class Device < ActiveRecord::Base

  def alert_recipient_ids=(list)
    self.alert_recipients = account.alert_recipients.find(
      list.reject {|a| a.blank?}
    )
  end

  def after_hours_start_text
    seconds_to_text(after_hours_start)
  end

  def after_hours_start_text=(text)
    self.after_hours_start = text_to_seconds(text)
  end

  def after_hours_end_text
    seconds_to_text(after_hours_end)
  end

  def after_hours_end_text=(text)
    self.after_hours_end = text_to_seconds(text)
  end

end
