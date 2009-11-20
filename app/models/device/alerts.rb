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
  
  protected
  
  # Can this be simplified or replaced with a standard function somewhere?
  def seconds_to_text(sec)
    return '12:00 am' unless sec

    min = ( sec / 60) % 60
    hr = sec / 3600
    ampm = (hr >= 12 ? 'pm' : 'am')
    hr = hr % 12
    hr = 12 if hr == 0
    "%02d:%02d %s" % [hr, min, ampm]
  end

  # Can this be simplified or replaced with a standard function somewhere?
  def text_to_seconds(text)
    text =~ /(\d+):(\d+) ?(\S+)/
    ($1.to_i % 12) * 3600 + $2.to_i * 60 + ($3 == 'pm' ? 43200 : 0)
  end
end
