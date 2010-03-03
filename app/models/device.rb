class Device < ActiveRecord::Base
  belongs_to :account
  belongs_to :user
  belongs_to :tracker
  belongs_to :device_profile
  has_many :points, :order => 'occurred_at'
  has_many :trips, :order => 'start'
  has_many :device_geofences, :dependent => :delete_all
  has_many :geofences, :through => :device_geofences
  has_many :device_alert_recipients, :dependent => :delete_all
  has_many :alert_recipients, :through => :device_alert_recipients
  has_many :events, :through => :points
  has_many :device_tags, :dependent => :delete_all
  has_many :tags, :through => :device_tags, :order => 'name'
  
  include TimeAsText
  time_as_text :after_hours_start
  time_as_text :after_hours_end
  
  # Last known position
  has_one :position, :class_name => 'Point', :order => 'occurred_at DESC',
    :conditions => 'latitude <> 0 OR longitude <> 0', :readonly => true

  # Virtual attribute for imei
  attr_accessor :imei_number

  # Link to groups
  has_and_belongs_to_many :groups, 
    :join_table => :group_links, 
    :foreign_key => :link_id,
    :order => "name ASC",
    :uniq => true

  VALID_SPEED_THRESHOLDS = [50, 55, 60, 65, 70, 75, 80, 85]
  VALID_RPM_THRESHOLDS = [2000, 2500, 3000, 3500, 4000, 4500, 5000, 5500, 6000, 6500, 7000, 7500, 8000]
  VALID_IDLE_THRESHOLDS = [4, 6, 8, 10, 20, 30]
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
    :odometer, :user, :time_zone, :detect_pitstops, :pitstop_threshold,
    :tags, :tag_names, :device_profile, :device_profile_id, :lock_vin,
    :groups, :imei_number

  before_save :prefill_profile_fields
  before_save :convert_imei_to_tracker
  after_create :assign_phones

  # Get the list of all the NON marked-for-deletion cars
  named_scope :active, {:conditions => "to_be_deleted IS NULL OR to_be_deleted = FALSE"}

  ##
  # Concerns
  ##
  concerned_with :sphinx
  concerned_with :alerts
  concerned_with :points

  ROLLOVER_MILES = 10000
  TRIP_REPORT_CUTOFF = 75.minutes

  # Build an array that contains all group names this device is a part of
  def group_names
    self.groups.map {|g| g.name }
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

  protected

  def convert_imei_to_tracker
    self.tracker = account.trackers.find_by_imei_number(self.imei_number)
  end

  def prefill_profile_fields
    if device_profile
      self.attributes = device_profile.updates_for_device
    end
  end

  def assign_phones
    if phones.empty?
      phones << account.phones
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
end
