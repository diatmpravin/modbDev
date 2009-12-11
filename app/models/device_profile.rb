class DeviceProfile < ActiveRecord::Base
  belongs_to :account
  has_many :devices, :dependent => :nullify
  
  include TimeAsText
  time_as_text :after_hours_start
  time_as_text :after_hours_end
  
  attr_accessible :account, :devices, :speed_threshold, :rpm_threshold,
    :alert_on_speed, :alert_on_aggressive, :alert_on_idle, :idle_threshold,
    :alert_on_after_hours, :after_hours_end, :after_hours_start, :detect_pitstops,
    :pitstop_threshold, :idle_threshold, :time_zone, :name
  
  validates_presence_of :name
  validates_length_of :name, :maximum => 30,
    :allow_nil => true, :allow_blank => true
  validates_inclusion_of :time_zone, :in => ActiveSupport::TimeZone.us_zones.map {|z| z.name}

  after_save :update_devices
  
  
  def update_devices
    updates = [
      alert_on_speed.nil? ? {} : {
        :alert_on_speed => alert_on_speed,
        :speed_threshold => speed_threshold
      },
      alert_on_aggressive.nil? ? {} : {
        :alert_on_aggressive => alert_on_aggressive,
        :rpm_threshold => rpm_threshold
      },
      alert_on_idle.nil? ? {} : {
        :alert_on_idle => alert_on_idle,
        :idle_threshold => idle_threshold 
      },
      alert_on_after_hours.nil? ? {} : {
        :alert_on_after_hours => alert_on_after_hours,
        :after_hours_start => after_hours_start,
        :after_hours_end => after_hours_end
      },
      detect_pitstops.nil? ? {} : {
        :detect_pitstops => detect_pitstops,
        :pitstop_threshold => pitstop_threshold
      },
      time_zone.blank? ? {} : {
        :time_zone => time_zone
      }
    ].inject {|hash, x| hash.merge(x)}

    if updates.any?
      account.devices.update_all(updates, {:device_profile_id => self.id})
    end
  end
  
end

