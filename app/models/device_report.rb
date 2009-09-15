class DeviceReport
  
  # Event codes reported by the device
  module Event
    PERIODIC_IGNITION_ON = 4001
    PERIODIC_IGNITION_OFF = 4002
    PERIODIC_HEARTBEAT = 4006
    
    DIRECTION = 6001
    SPEED = 6002
    RPM = 6003
    GEOFENCE = 6004
    MILEAGE = 6005
    ACCELERATING = 6006
    DECELERATING = 6007
    BATTERY = 6008
    IGNITION_ON = 6011
    IGNITION_OFF = 6012
    RESET = 6015
    IDLE = 6016
    TOWING_START = 6017
    TOWING_STOP = 6018
    
    REPORT = 7001
    VEHICLE_INFO = 7002
  end
  
  # Formats for the various report types
  module Format
    POINT_REPORT = [
      :imei,
      :event,
      :date,
      :time,
      :latitude,
      :longitude,
      :altitude,
      :speed,
      :accelerating,
      :decelerating,
      :rpm,
      :heading,
      :satellites,
      :hdop,
      :miles,
      :mpg,
      :battery,
      :signal,
      :gps
    ]
    
    EXTENDED_REPORT = POINT_REPORT + [
      :fw_version,
      :obd_fw_version,
      :profile,
      :vin
    ]
    
    def for(event)
      case event.to_i
        when DeviceReport::Event::PERIODIC_HEARTBEAT
          EXTENDED_REPORT
        when DeviceReport::Event::RESET
          EXTENDED_REPORT
        else
          POINT_REPORT
      end
    end
    
    module_function :for
  end
  
  # Attempt to parse the given string report and create a hash containing
  # the appropriate key/value pairs.
  def self.parse(report_string)
    return nil unless report_string.scan(/\$\$.*?##/).any?
    report = report_string[2..-3].split(',')
    
    # The second field of the report is always the event type
    format = Format.for(report[1])
    hash = {}
    
    format.each_with_index do |key, index|
      hash[key] = report[index] if report[index]
    end
    
    hash
  end
end