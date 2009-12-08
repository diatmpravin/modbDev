class Device < ActiveRecord::Base
  belongs_to :account
  belongs_to :user
  belongs_to :tracker
  belongs_to :device_profile
  has_many :points, :order => 'occurred_at'
  has_many :trips, :order => 'start'
  has_many :phone_devices, :dependent => :delete_all
  has_many :phones, :through => :phone_devices
  has_many :device_geofences, :dependent => :delete_all
  has_many :geofences, :through => :device_geofences
  has_many :device_alert_recipients, :dependent => :delete_all
  has_many :alert_recipients, :through => :device_alert_recipients
  has_many :events, :through => :points
  has_many :device_tags, :dependent => :delete_all
  has_many :tags, :through => :device_tags, :order => 'name'
  
  # Last known position
  has_one :position, :class_name => 'Point', :order => 'occurred_at DESC',
    :conditions => 'latitude <> 0 OR longitude <> 0', :readonly => true

  # Link to groups
  has_and_belongs_to_many :groups, 
    :join_table => :group_links, 
    :foreign_key => :link_id,
    :order => "name ASC"

  VALID_SPEED_THRESHOLDS = [50, 55, 60, 65, 70, 75, 80, 85]
  VALID_RPM_THRESHOLDS = [2000, 2500, 3000, 3500, 4000, 4500, 5000, 5500, 6000, 6500, 7000, 7500, 8000]
  VALID_IDLE_THRESHOLDS = [1, 2, 3, 4, 5, 10, 15, 20]
  VALID_PITSTOP_THRESHOLDS = [5, 10, 15, 20, 30, 45, 60]

  validates_presence_of :tracker, :message => 'is not valid'
  validates_uniqueness_of :tracker_id, :message => 'is already in use'
  validates_presence_of :name
  validates_length_of :name, :maximum => 30,
    :allow_nil => true, :allow_blank => true
  validates_inclusion_of :time_zone, :in => ActiveSupport::TimeZone.us_zones.map {|z| z.name}

  validates_numericality_of :odometer, :allow_nil => true

  attr_accessible :name, :account, :points, :trips, :phone_devices, :phones,
    :geofences, :color_id, :speed_threshold, :rpm_threshold, :alert_on_speed,
    :alert_on_aggressive, :alert_recipients, :alert_on_idle,
    :alert_on_after_hours, :idle_threshold, :after_hours_start,
    :after_hours_end, :alert_recipient_ids, :alert_recipients,
    :vin_number, :after_hours_start_text, :after_hours_end_text,
    :odometer, :user, :time_zone, :detect_pitstops, :pitstop_threshold,
    :tags, :tag_names, :device_profile, :device_profile_id

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

  # Shortcut for IMEI number
  def imei_number
    self.tracker ? tracker.imei_number : nil
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
    self.device_profile = value ? account.device_profiles.find(value) : nil
  end
  
  def zone
    ActiveSupport::TimeZone[self[:time_zone]]
  end
  
  # Connected flag
  def connected
    position && Time.now - position.occurred_at < TRIP_REPORT_CUTOFF
  end

  def color
    Color.find(color_id)
  end

  # Get a DataAggregate object containing trip and point data for a given day
  def data_for(day = self.user.zone.today)
    DataAggregator.new.tap do |da|
      da.trips = self.trips.in_range(day, day, self.user.zone).all
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

  def assign_phones
    if phones.empty?
      phones << account.phones
    end
  end
end
