class DeviceProfile < ActiveRecord::Base
  belongs_to :account
  has_many :devices, :dependent => :nullify
  
  include TimeAsText
  time_as_text :after_hours_start
  time_as_text :after_hours_end
  
  attr_accessible :account, :devices, :speed_threshold, :rpm_threshold,
    :alert_on_speed, :alert_on_aggressive, :alert_on_idle, :alert_on_reset, 
    :idle_threshold, :alert_on_after_hours, :after_hours_end, :after_hours_start, 
    :detect_pitstops, :pitstop_threshold, :idle_threshold, :time_zone, :name
  
  PROFILE_ATTRIBUTES = [
    :alert_on_speed,
    :speed_threshold,
    :alert_on_aggressive,
    :rpm_threshold,
    :alert_on_idle,
    :idle_threshold,
    :alert_on_after_hours,
    :after_hours_start,
    :after_hours_end,
    :alert_on_reset,
    :detect_pitstops,
    :pitstop_threshold,
    :time_zone
  ]
  
  validates_presence_of :name
  validates_length_of :name, :maximum => 30,
    :allow_nil => true, :allow_blank => true
  validates_inclusion_of :time_zone, :in => ActiveSupport::TimeZone.us_zones.map {|z| z.name}

  after_save :update_devices
  
  def updates_for_device
    PROFILE_ATTRIBUTES.inject({}) {|hash, x| hash.merge(x => self[x])}
  end
  
  def update_devices
    account.devices.update_all(updates_for_device, {:device_profile_id => self.id})
  end
  
  def to_json(options = {})
    super(options.merge(
      :methods => [:after_hours_start_text, :after_hours_end_text]
    ))
  end
end

