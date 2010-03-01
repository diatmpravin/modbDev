class Device < ActiveRecord::Base

  ##
  # Handle a report from the physical device
  #
  # TODO: Too much stuff in this method. Split apart geofence, thresholds, and trip handling
  def process(report)
    unless report[:event] == DeviceReport::Event::VEHICLE_INFO.to_s
      # Handle special data
      if report[:vin]
        self.fw_version = report[:fw_version]
        self.obd_fw_version = report[:obd_fw_version]
        self.profile = report[:profile]

        if !self.lock_vin? ||
          (self.vin_number.blank? || self.vin_number == '0')
          self.vin_number = report[:vin]
        end

        self.reported_vin_number = report[:vin]
        self.save
        
        # VIN Mismatch Alert
        if report[:event] == DeviceReport::Event::RESET.to_s &&
            self.vin_number != self.reported_vin_number
          alert_recipients.each do |r|
            r.alert("#{self.name} VIN Mismatch", self.zone.now)
          end
        end
      end

      # Last reported point for this device
      last_point = points.last

      # Last reported trip marker point
      trip_point = points.trip_markers.last

      point = points.new
      point.parse(report)

      # Handle trip activity
      if trip_point && trip_point.running? &&
          point.occurred_at < trip_point.occurred_at + TRIP_REPORT_CUTOFF &&
          point.event != Point::IGNITION_ON
        if point.miles < trip_point.miles
          # If the mileage rolled over, create a new leg on the trip.
          # Not perfect, but eliminates the "9000 mile" problem.
          point.leg = trip_point.leg.trip.legs.create
        elsif !point.trip_marker?
          point.leg = trip_point.leg
        elsif point.running?
          point.leg = trip_point.leg
        elsif point.event == Point::IGNITION_OFF
          # We want to include the "ignition off" as the last point of the trip
          point.leg = trip_point.leg
        end
      elsif point.trip_marker? && point.running?
        # Decide whether to create a new leg on the last known trip,
        # or create the first leg of a brand new trip.
        if trip_point && trip_point.leg && detect_pitstops? &&
            point.occurred_at - trip_point.occurred_at < pitstop_threshold.minutes
          point.leg = trip_point.leg.trip.legs.create
        else
          point.leg = trips.create.legs.create
        end
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
      
      # VIN Mismatch Events
      if !(self.vin_number.blank? || self.reported_vin_number.blank?) &&
          self.vin_number != self.reported_vin_number
        point.events.create(:event_type => Event::VIN_MISMATCH)
      end
      
      # Handle boundary testing for geofences linked to this vehicle or
      # any of this vehicle's groups.
      geofences_to_test = geofences + account.geofences.all(
        :joins => :device_groups,
        :conditions => {:geofence_device_groups => {:group_id => groups.map(&:id)}}
      )
      
      if last_point
        geofences_to_test.each do |fence|
          if fence.contain?(point) && !fence.contain?(last_point)
            point.events.create(:event_type => Event::ENTER_BOUNDARY, :geofence_name => fence.name)
            if fence.alert_on_entry?
              fence.alert_recipients.each do |r|
                r.alert("#{self.name} entered area #{fence.name}", self.zone.now)
              end
            end
          elsif !fence.contain?(point) && fence.contain?(last_point)
            point.events.create(:event_type => Event::EXIT_BOUNDARY, :geofence_name => fence.name)
            if fence.alert_on_exit?
              fence.alert_recipients.each do |r|
                r.alert("#{self.name} exited area #{fence.name}", self.zone.now)
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

      # Speed alert, if flagged and if a new point is > 5 mph from the previous speed alert point
      if alert_on_speed? && point.speed > speed_threshold
        point.events.create(:event_type => Event::SPEED, :speed_threshold => speed_threshold)

        if !last_point || last_point.speed <= speed_threshold
          alert_recipients.each do |r|
            r.alert("#{self.name} speed reached #{point.speed} mph (exceeded limit of #{speed_threshold} mph)", self.zone.now)
          end
        end
      end

      # rpm_threshold is static at the moment (but maybe not forever)
      if point.rpm > rpm_threshold
        point.events.create(:event_type => Event::RPM, :rpm_threshold => rpm_threshold)
        if alert_on_aggressive?
          alert_recipients.each do |r|
            r.alert("#{self.name} experienced excessive RPM", self.zone.now)
          end
        end
      end

      if point.event == DeviceReport::Event::ACCELERATING
        point.events.create(:event_type => Event::RAPID_ACCEL)
        if alert_on_aggressive?
          alert_recipients.each do |r|
            r.alert("#{self.name} experienced rapid acceleration", self.zone.now)
          end
        end
      end

      if point.event == DeviceReport::Event::DECELERATING
        point.events.create(:event_type => Event::RAPID_DECEL)
        if alert_on_aggressive?
          alert_recipients.each do |r|
            r.alert("#{self.name} experienced rapid deceleration", self.zone.now)
          end
        end
      end

      # idle event
      unless point.leg.nil?
        #if dist between point and last trip point with time > threshold for vehicle
        #is within idle distance threshold, set the point event to idle
        start_idle_window = point.leg.points.before(self.idle_threshold.minutes.ago(point.occurred_at)).last
        unless start_idle_window.nil?
          idle_window_points = self.points.in_range(start_idle_window.occurred_at, point.occurred_at, self.zone)

          if idle_window_points.reject!{|p| p.speed != 0}.nil?
            #if the previous point has an event... steal it?
            pre = point.leg.points.before(point.occurred_at).last
            pre_event = pre.events.find_last_by_event_type(Event::IDLE)

            if (pre_event.nil?)
              point.events.create(:event_type => Event::IDLE)
              if alert_on_idle?
                alert_recipients.each do |r|
                  r.alert("#{self.name} idled for an extended period", self.zone.now)
                end
              end
            else
              pre_event.point = point
              pre_event.save
            end

          end
        end
      end

      if alert_on_after_hours? && point_is_after_hours?(point) && point.leg
        point.events.create(:event_type => Event::AFTER_HOURS)

        # Get the point right before this one
        # TODO Better handling of last_point above?
        last = point.leg.points[-2]

        # If the previous point is NOT an after_hours event, then we send
        # our alert. Otherwise, we assume the alert has already been sent
        if !last ||
           !last.events.exists?(:event_type => Event::AFTER_HOURS)
          alert_recipients.each do |r|
            r.alert("#{self.name} is running after hours", self.zone.now)
          end
        end
      end

    end
  end

  protected

  def point_is_after_hours?(point)
    tod = point.occurred_at.in_time_zone(zone)
    tod -= tod.beginning_of_day

    if after_hours_start <= after_hours_end
      tod >= after_hours_start && tod <= after_hours_end
    else
      tod >= after_hours_start || tod <= after_hours_end
    end
  end

  
end
