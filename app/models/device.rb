class Device < ActiveRecord::Base
  belongs_to :account
  belongs_to :tracker
  belongs_to :device_profile
  belongs_to :group, :class_name => 'DeviceGroup'
  has_many :points, :order => 'occurred_at'
  has_many :trips, :order => 'start'
  has_many :device_alert_recipients, :dependent => :delete_all
  has_many :alert_recipients, :through => :device_alert_recipients
  has_many :events, :through => :points
  has_many :device_tags, :dependent => :delete_all
  has_many :tags, :through => :device_tags, :order => 'name'

  has_many :daily_data, :class_name => "DeviceDataPerDay"

  include TimeAsText
  time_as_text :after_hours_start
  time_as_text :after_hours_end

  # Last known position
  has_one :position, :class_name => 'Point', :order => 'occurred_at DESC',
    :conditions => 'latitude <> 0 OR longitude <> 0', :readonly => true

  # Virtual attribute for imei
  attr_accessor :imei_number

  VALID_SPEED_THRESHOLDS = [50, 55, 60, 65, 70, 75, 80, 85]
  VALID_RPM_THRESHOLDS = [2000, 2500, 3000, 3500, 4000, 4500, 5000, 5500, 6000, 6500, 7000, 7500, 8000]
  VALID_IDLE_THRESHOLDS = [10, 15, 20, 25, 30]
  VALID_PITSTOP_THRESHOLDS = [5, 10, 15, 20, 30, 45, 60]

#  validates_presence_of :tracker, :message => 'is not valid'
#  validates_uniqueness_of :tracker_id, :message => 'is already in use'
  validates_presence_of :name
  validates_length_of :name, :maximum => 30,
    :allow_nil => true, :allow_blank => true
  validates_inclusion_of :time_zone, :in => ActiveSupport::TimeZone.us_zones.map {|z| z.name}
  validate :tracker_available

  validates_numericality_of :odometer, :allow_nil => true

  attr_accessible :name, :account, :points, :trips, :phone_devices,
    :geofences, :color_id, :speed_threshold, :rpm_threshold, :alert_on_speed,
    :alert_on_aggressive, :alert_recipients, :alert_on_idle, :alert_on_reset,
    :alert_on_after_hours, :idle_threshold, :after_hours_start,
    :after_hours_end, :alert_recipient_ids, :alert_recipients, :vin_number,
    :odometer, :time_zone, :detect_pitstops, :pitstop_threshold,
    :tags, :tag_names, :device_profile, :device_profile_id, :lock_vin,
    :group, :group_id, :imei_number

  before_save :prefill_profile_fields, :convert_imei_to_tracker, :update_thresholds

  # Devices that aren't currently in any group
  named_scope :ungrouped, {:conditions => {:group_id => nil}}
  
  ##
  # Concerns
  ##
  concerned_with :sphinx
  concerned_with :alerts
  concerned_with :points
  concerned_with :jobs

  ROLLOVER_MILES = 10000
  TRIP_REPORT_CUTOFF = 75.minutes
  NOT_REPORTING_THRESHOLD = 130.minutes

  # Return the group name
  def group_name
    group ? group.name : ''
  end

  # Shortcut for IMEI number
  def imei_number
    @imei_number || (self.tracker ? tracker.imei_number : nil)
  end

  # Save tag names as tags
  def tag_names=(list)
    # Throw away extra space and blank tags
    list = list.map {|x| x.strip}.reject {|x| x.blank?}

    # Re-use any tags that already exist
    self.tags = account.tags.all(:conditions => {:name => list})
    tag_names = self.tags.map(&:name)

    # Create new tags for any names left in the list
    list.reject! {|x| tag_names.find {|name| name.casecmp(x) == 0}}
    self.tags += account.tags.create(list.map {|n| {:name => n}}).select(&:valid? )
  end

  # Safe device_profile_id=
  def device_profile_id=(value)
    self.device_profile = value.blank? ? nil : account.device_profiles.find(value)
  end

  # Safe group_id=
  def group_id=(value)
    self.group = value.blank? ? nil : account.groups.find(value)
  end
  
  def zone
    ActiveSupport::TimeZone[self[:time_zone] || "Eastern Time (US & Canada)"]
  end

  # Connected flag
  def connected
    position && Time.now - position.occurred_at < TRIP_REPORT_CUTOFF
  end

  def color
    Color.find(color_id)
  end

  # Get a DataAggregate object containing trip and point data for a given day
  def data_for(day, zone)
    DataAggregator.new.tap do |da|
      da.trips = self.trips.in_range(day, day, zone).all
    end
  end

  # Get a string representation of the device's current status
  def current_status
    if self.position
      if self.position.running?
        if (speed = self.position.speed) > 0
          "Moving at #{speed} mph"
        else
          "Idle"
        end
      else
        "Stationary"
      end
    else
      "No Data"
    end
  end

  # Get a single aggregate object that pulls in all data
  # over a given range
  def daily_data_over(from, to)
    from = from.to_date; to = to.to_date
    #aggregate = DeviceDataPerDay.new

    #self.daily_data.for_range(from, to).each do |data|
    #  aggregate.merge!(data)
    #end

    #aggregate
    DeviceDataPerDay.all(:select => "AVG(duration) as duration_avg,
                                     AVG(miles) as miles_avg,
                                     AVG(speed_events) as speed_events_avg,
                                     AVG(geofence_events) as geofence_events_avg,
                                     AVG(idle_events) as idle_events_avg,
                                     AVG(aggressive_events) as aggressive_events_avg,
                                     AVG(after_hours_events) as after_hours_events_avg,
                                     AVG(mpg) as mpg_avg,
                                     AVG(first_start) as first_start_avg,
                                     AVG(last_stop) as last_stop_avg",
                         :conditions => {:date => from..to, :device_id => self.id})
  end

  protected

  def convert_imei_to_tracker
    self.tracker = account.trackers.find_by_imei_number(self.imei_number)
  end

  def prefill_profile_fields
    if device_profile
      self.attributes = device_profile.updates_for_device
    end
  end

  def tracker_available
    if self.imei_number && self.imei_number != ''
      t = self.account.trackers.find_by_imei_number(self.imei_number)
      if !t
         errors.add(:imei_number, ' is not owned by this account')
      elsif t.device && t.device.id != self.id
         errors.add(:imei_number, ' is already assigned to another vehicle')
      end
    end
  end

  # Kicks off a background job to update the threshold options on the tracker.
  def update_thresholds
    return if tracker.nil?

    updates = {}

    # First check to see if any of the values for the various thresholds have changed
    if(speed_threshold_changed? || tracker_id_changed?)
      updates[:speed] = self.speed_threshold
    end

    if(rpm_threshold_changed? || tracker_id_changed?)
      updates[:rpm] = self.rpm_threshold
    end

    if(idle_threshold_changed? || tracker_id_changed?)
      updates[:idle] = self.idle_threshold
    end

    # Next we need to see if any of them have been disabled or enabled. If they
    # have then we need to make sure they are disabled on the device or set to
    # the proper threshold.
    if(alert_on_speed_changed? || tracker_id_changed?)
      updates[:speed] = alert_on_speed ? self.speed_threshold : 0
    end

    if(alert_on_aggressive_changed? || tracker_id_changed?)
      updates[:rpm] = alert_on_aggressive ? self.rpm_threshold : 0
    end

    if(alert_on_idle_changed? || tracker_id_changed?)
      updates[:idle] = alert_on_idle ? self.idle_threshold : 0
    end

    # Finally send the updates if there are any to send
    tracker.async_configure(updates) if updates.any?
  end

end
