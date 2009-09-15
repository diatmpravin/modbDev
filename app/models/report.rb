class Report
  attr_accessor :account, :report_type, :range_type, :start_date,
    :end_date, :devices, :title, :error
  
  REPORT_TYPES = {
    0 => 'Vehicle Summary Report',
    1 => 'Daily Summary Report',
    2 => 'Event Detail Report'
  }
  
  RANGE_TYPES = {
    0 => 'Date Range'
  }
  
  def self.type_options
    REPORT_TYPES.invert
  end
  
  def self.range_options
    RANGE_TYPES.invert
  end
  
  def initialize(account, opts = {})
    opts = opts.with_indifferent_access
    
    @account = account
    @report_type = opts[:report_type].to_i if opts[:report_type]
    @range_type = opts[:range_type].to_i if opts[:range_type]
    @start_date = opts[:start_date] if opts[:start_date]
    @end_date = opts[:end_date] if opts[:end_date]
    @devices = opts[:devices].map{|d| d.to_i} if opts[:devices]
  end
  
  def data
    @data ||= run
  end
  
  # Generate the actual report in the appropriate "raw" data form (array,
  # hash, etc.)
  def run
    return nil unless @report_type
    
    # Check for valid dates
    unless @start_date =~ /^\d\d\/\d\d\/\d\d\d\d$/ &&
           @end_date =~ /^\d\d\/\d\d\/\d\d\d\d$/
      @error = 'You must specify valid start and end dates'
      return nil
    end
    
    case report_type
      when 0
        run_vehicle_summary_report
      when 1
        run_daily_summary_report
      when 2
        run_event_detail_report
      else
        nil
    end
  end
  
  protected
  def run_vehicle_summary_report
    report = []
    
    if !@devices || @devices.blank?
      @error = 'You must choose one or more vehicles to run this report'
      return nil
    end
    
    Device.find(@devices).each do |device|
      trips = device.trips.in_range(@start_date, @end_date, @account.zone)
      
      # Do event grouping in database
      events = device.events.in_range(@start_date, @end_date, @account.zone).all(
        :select => 'event_type, COUNT(*) AS count_all',
        :group => :event_type
      ).map {|e| [e.event_type, e.count_all.to_i]}
      
      # Hashify
      events = Hash[*events.inject([]) {|arr, elem| arr.concat(elem)}]
      
      report << {
        :name => device.name,
        :miles => trips.map {|t| t.miles}.sum,
        :duration => pretty_duration(trips.map {|t| t.duration}.sum),
        :idle_time => pretty_duration(trips.map {|t| t.idle_time}.sum),
        :events => {
          :speed => events[Event::SPEED] || 0,
          :geofence => [
            events[Event::ENTER_BOUNDARY] || 0,
            events[Event::EXIT_BOUNDARY] || 0
          ].sum,
          :idle_time => events[Event::IDLE] || 0,
          :aggressive => [
            events[Event::RPM] || 0,
            events[Event::RAPID_ACCEL] || 0,
            events[Event::RAPID_DECEL] || 0
          ].sum,
          :after_hours => events[Event::AFTER_HOURS] || 0
        }
      }
    end
    
    @title = "Vehicle Summary Report - #{@start_date} through #{@end_date}"
    
    report
  end
  
  def run_daily_summary_report
    if !@devices || @devices.length != 1
      @error = 'You must choose one vehicle to run this report'
      return nil
    end
    
    date_range = [Date.parse(@start_date), Date.parse(@end_date)]
    device = Device.find(@devices[0])
    report = []
    
    # Get info for each day, relying on database calc wherever possible
    date_conditions = [
      'DATE(start) BETWEEN ? AND ?',
      *date_range.map {|d| d.to_s(:db)}
    ]
    
    miles = device.trips.sum(:miles, :group => 'DATE(start)',
      :conditions => date_conditions)
    
    duration = device.trips.sum('TIME_TO_SEC(TIMEDIFF(finish, start))', :group => 'DATE(start)',
      :conditions => date_conditions)
    
    idle_time = device.trips.sum(:idle_time, :group => 'DATE(start)',
      :conditions => date_conditions)
    
    # Do event grouping in database
    events = device.events.in_range(@start_date, @end_date, @account.zone).all(
      :select => 'DATE(events.occurred_at) AS date, event_type, COUNT(*) AS count_all',
      :group => 'DATE(events.occurred_at), event_type'
    ).map {|e| [[e.date, e.event_type], e.count_all.to_i]}
    
    # Hashify
    events = Hash[*events.inject([]) {|arr, elem| arr.concat(elem)}]
    
    # Package up the info by date
    Range.new(*date_range).each do |date|
      index = date.to_s(:db)
      
      report << {
        :date => date,
        :miles => miles[index] || 0,
        :duration => pretty_duration(duration[index] || 0),
        :idle_time => pretty_duration(idle_time[index] || 0),
        :events => {
          :speed => events[[index, Event::SPEED]] || 0,
          :geofence => [
            events[[index, Event::ENTER_BOUNDARY]] || 0,
            events[[index, Event::EXIT_BOUNDARY]] || 0
          ].sum,
          :idle_time => events[[index, Event::IDLE]] || 0,
          :aggressive => [
            events[[index, Event::RPM]] || 0,
            events[[index, Event::RAPID_ACCEL]] || 0,
            events[[index, Event::RAPID_DECEL]] || 0
          ].sum,
          :after_hours => events[[index, Event::AFTER_HOURS]] || 0
        }
      }
    end
    
    @title = "Daily Summary Report for #{device.name} - #{@start_date} through #{@end_date}"
    
    report
  end
  
  def run_event_detail_report
    report = []
    
    if !@devices || @devices.blank?
      @error = 'You must choose one or more vehicles to run this report'
      return nil
    end
    
    # Custom find in order to pull in the device name
    events = Event.in_range(@start_date, @end_date, @account.zone).all(
      :joins => 'INNER JOIN points ON events.point_id = points.id ' +
                'INNER JOIN devices ON points.device_id = devices.id',
      :conditions => {'points.device_id' => @devices},
      :order => 'events.occurred_at',
      :select => 'events.*, devices.name AS device_name'
    )
    
    events.each do |event|
      report << {
        :date => event.occurred_at.to_date.to_s,
        :time => event.occurred_at.to_time.to_s(:local),
        :device => event.device_name,  # attribute from custom find
        :text => event.type_text
      }
    end
    
    @title = "Event Detail Report - #{@start_date} through #{@end_date}"
    
    report
  end
  
  def pretty_duration(seconds)
    minutes = seconds.to_i / 60
    
    "%02d:%02d" % [minutes / 60, minutes % 60]
  end
end