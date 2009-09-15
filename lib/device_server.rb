require 'eventmachine'

# Accepts incoming commands from OBD devices and creates database rows
# where appropriate.
#
# Each command starts with "$$" and ends with "##". A device can send more
# than one command during a single connection.
#
module DeviceServer
  include WithActiveRecord
  include LoadsYamlConfig
  loads_yaml_config :servers, 'device_server.yml'
  
  def post_init
    @buffer = ""
  end

  def receive_data(data)
    @buffer << data
    
    if report = @buffer.slice!(/\$\$.*?##/)
      EventMachine.defer(proc {
        handle_report report
      })
    end
  end
  
  def handle_report(report_string)
    with_active_record do
      log report_string
      
      report = DeviceReport.parse(report_string)
      tracker = Tracker.find_by_imei_number(report[:imei])
      
      if tracker
        log "  - tracker #{tracker.id}"
        if tracker.device
          tracker.device.process(report)
        end
      end
    end
  end
  
  def log(message)
    @@logger ||= Logger.new(File.join(RAILS_ROOT, 'log', 'device_server.log'))
    @@logger.info "#{Time.now.strftime("%Y-%m-%d %H:%M:%S")} #{message}"
  end
  module_function :log
  
  ##
  # Start the Device Server
  #
  def run
    log "Device Server started"
    
    EventMachine::run do
      servers.each_value do |server|
        if server[:type] == 'udp'
          EventMachine::open_datagram_socket server[:host], server[:port], DeviceServer
        else
          EventMachine::start_server server[:host], server[:port], DeviceServer
        end
      end
    end
  ensure
    log "Device Server stopped"
  end
  module_function :run
end