class Device < ActiveRecord::Base
  belongs_to :account
  belongs_to :user
  belongs_to :tracker
  has_many :points, :order => 'occurred_at'
  has_many :trips, :order => 'start'
  has_many :phone_devices, :dependent => :delete_all
  has_many :phones, :through => :phone_devices
  has_many :device_geofences, :dependent => :delete_all
  has_many :geofences, :through => :device_geofences
  has_many :device_alert_recipients, :dependent => :delete_all
  has_many :alert_recipients, :through => :device_alert_recipients
  has_many :events, :through => :points

  has_one :position, :class_name => 'Point', :order => 'occurred_at DESC', :readonly => true

  VALID_SPEED_THRESHOLDS = [50, 55, 60, 65, 70, 75, 80, 85]
  VALID_RPM_THRESHOLDS = [2000, 2500, 3000, 3500, 4000, 4500, 5000, 5500, 6000, 6500, 7000, 7500, 8000]
  VALID_IDLE_THRESHOLDS = [1, 2, 3, 4, 5, 10, 15, 20]

  validates_presence_of :tracker, :message => 'is not valid'
  validates_uniqueness_of :tracker_id, :message => 'is already in use'
  validates_length_of :name, :maximum => 30,
    :allow_nil => true, :allow_blank => true
  validates_inclusion_of :time_zone, :in => ActiveSupport::TimeZone.us_zones.map {|z| z.name}

  validates_numericality_of :odometer, :allow_nil => true

  validate_on_create :validate_number_of_records

  attr_accessible :name, :account, :points, :trips, :phone_devices, :phones,
    :geofences, :color_id, :speed_threshold, :rpm_threshold, :alert_on_speed,
    :alert_on_aggressive, :alert_recipients, :alert_on_idle,
    :alert_on_after_hours, :idle_threshold, :after_hours_start,
    :after_hours_end, :alert_recipient_ids, :alert_recipients,
    :vin_number, :after_hours_start_text, :after_hours_end_text,
    :odometer, :user, :time_zone

  after_create :assign_phones

  # Get the list of all the NON marked-for-deletion cars
  named_scope :active, {:conditions => "to_be_deleted IS NULL OR to_be_deleted = FALSE"}

  ROLLOVER_MILES = 10000
  TRIP_REPORT_CUTOFF = 75.minutes

  # Shortcut for IMEI number
  def imei_number
    self.tracker ? tracker.imei_number : nil
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

  # Get a DataAggregate object containing trip and point data for a given day
  def data_for(day = self.user.zone.today)
    DataAggregator.new.tap do |da|
      da.points = self.points.in_range(day, day, self.user.zone)
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

  ##
  # Handle a report from the physical device
  #
  # TODO: Too much stuff in this method. Split apart geofence, thresholds, and trip handling
  def process(report)
    unless report[:event] == DeviceReport::Event::VEHICLE_INFO
      # Handle special data
      if report[:vin]
        self.fw_version = report[:fw_version]
        self.obd_fw_version = report[:obd_fw_version]
        self.profile = report[:profile]
        self.reported_vin_number = report[:vin]
        self.save
      end

      # Last reported point for this device
      last_point = points.last

      # Last reported trip marker point
      trip_point = points.trip_markers.last

      point = points.new
      point.parse(report)

      # Handle trip activity
      if trip_point && trip_point.running? &&
          point.occurred_at < trip_point.occurred_at + TRIP_REPORT_CUTOFF
        if !point.trip_marker?
          point.leg = trip_point.leg
        elsif point.running?
          point.leg = trip_point.leg
        elsif point.event == Point::IGNITION_OFF
          # We want to include the "ignition off" as the last point of the trip
          point.leg = trip_point.leg
        end
      elsif point.trip_marker? && point.running?
        point.leg = trips.create.legs.create
      end

      point.save
      self.reload # force "points.last" to be the newly added point

      # Handle odometer
      if self.odometer && point.miles && last_point.miles
        miles = point.miles - last_point.miles
        miles += ROLLOVER_MILES if miles < 0
        if miles > 0
          self.update_attribute(:odometer, self.odometer + miles)
        end
      end

      # Handle boundary testing for geofences
      if last_point
        geofences.each do |fence|
          if fence.contain?(point) && !fence.contain?(last_point)
            point.events.create(:event_type => Event::ENTER_BOUNDARY, :geofence_name => fence.name)
            if fence.alert_on_entry?
              fence.alert_recipients.each do |r|
                r.alert("#{self.name} entered area #{fence.name}")
              end
            end
          elsif !fence.contain?(point) && fence.contain?(last_point)
            point.events.create(:event_type => Event::EXIT_BOUNDARY, :geofence_name => fence.name)
            if fence.alert_on_exit?
              fence.alert_recipients.each do |r|
                r.alert("#{self.name} exited area #{fence.name}")
              end
            end
          end
        end
      end

      # Handle boundary testing for landmarks
      account.landmarks.each do |landmark|
        if landmark.contain?(point)
          point.events.create(:event_type => Event::AT_LANDMARK, :geofence_name => landmark.name)
        end
      end
      
      # Handle various other vehicle tests
      if point.speed > speed_threshold
        point.events.create(:event_type => Event::SPEED, :speed_threshold => speed_threshold)
        if alert_on_speed?
          alert_recipients.each do |r|
            r.alert("#{self.name} speed reached #{point.speed} mph (exceeded limit of #{speed_threshold} mph)")
          end
        end
      end

      # rpm_threshold is static at the moment (but maybe not forever)
      if point.rpm > rpm_threshold
        point.events.create(:event_type => Event::RPM, :rpm_threshold => rpm_threshold)
        if alert_on_aggressive?
          alert_recipients.each do |r|
            r.alert("#{self.name} experienced excessive RPM")
          end
        end
      end

      if point.event == DeviceReport::Event::ACCELERATING
        point.events.create(:event_type => Event::RAPID_ACCEL)
        if alert_on_aggressive?
          alert_recipients.each do |r|
            r.alert("#{self.name} experienced rapid acceleration")
          end
        end
      end

      if point.event == DeviceReport::Event::DECELERATING
        point.events.create(:event_type => Event::RAPID_DECEL)
        if alert_on_aggressive?
          alert_recipients.each do |r|
            r.alert("#{self.name} experienced rapid deceleration")
          end
        end
      end

      if point.event == Point::IDLE && alert_on_idle?
        point.events.create(:event_type => Event::IDLE)
        #if alert_on_idle?
          alert_recipients.each do |r|
            r.alert("#{self.name} idled for an extended period")
          end
        #end
      end

      if alert_on_after_hours? && point_is_after_hours?(point)
        if point.running? ||
           point.event == DeviceReport::Event::IGNITION_ON

          point.events.create(:event_type => Event::AFTER_HOURS)

          # If the previous point is NOT an after_hours event, then we send
          # our alert. Otherwise, we assume the alert has already been sent
          if !last_point ||
             !last_point.events.exists?(:event_type => Event::AFTER_HOURS)

            alert_recipients.each do |r|
              r.alert("#{self.name} is running after hours")
            end
          end
        end
      end

    end
  end
  
  protected
  def assign_phones
    if phones.empty?
      phones << account.phones
    end
  end

  def validate_number_of_records
    if Device.count(:conditions => {:account_id => account_id}) >= 20
      errors.add_to_base 'Too many devices'
    end
  end

  def point_is_after_hours?(point)
    tod = point.occurred_at.in_time_zone(account.zone)
    tod -= tod.beginning_of_day

    if after_hours_start <= after_hours_end
      tod >= after_hours_start && tod <= after_hours_end
    else
      tod >= after_hours_start || tod <= after_hours_end
    end
  end

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
