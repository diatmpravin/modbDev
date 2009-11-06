require 'eventmachine'

# Accepts incoming commands from OBD devices and creates database rows
# where appropriate.
#
# Each command starts with "$$" and ends with "##". A device can send more
# than one command during a single connection.
#
module DeviceServer
  include LoadsYamlConfig
  include Logging

  log_to 'device_server'
  loads_yaml_config :servers, 'device_server.yml'

  def post_init
    @buffer = ""
  end

  def receive_data(data)
    @buffer << data

    if report = @buffer.slice!(/\$\$.*?##/)
      EventMachine.defer(ReportHandler.new(report))
    end
  rescue Exception => e
    logger.error(e)
  end

  class ReportHandler
    include WithActiveRecord

    def initialize(report)
      @report = report
    end

    def logger
      DeviceServer.logger
    end

    def call
      with_active_record do
        logger.info(@report)

        report = DeviceReport.parse(@report)
        tracker = Tracker.find_by_imei_number(report[:imei])

        if tracker
          logger.info("  - tracker #{tracker.id}")
          if tracker.device
            tracker.device.process(report)
          end
        end
      end
    rescue Exception => e
      logger.error(e)
    end
  end

  ##
  # Start the Device Server
  #
  def run
    logger.info("Device Server started")

    EventMachine::run do
      begin
        servers.each_value do |server|
          if server[:type] == 'udp'
            EventMachine::open_datagram_socket server[:host], server[:port], DeviceServer
          else
            EventMachine::start_server server[:host], server[:port], DeviceServer
          end
        end
      rescue Exception => e
        logger.error(e)
      end
    end
  ensure
    logger.info("Device Server stopped")
  end
  module_function :run
end
