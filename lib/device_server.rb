require 'eventmachine'
require 'redis'

module DeviceServer
  include Logging

  log_to 'device_server'

  class Dispatcher
    def initialize
      # Redis-rb doesn't know about spop
      Redis::ALIASES["set_pop"] = "spop"
      @redis = Redis.build
    end

    def logger
      DeviceServer.logger
    end

    # Configure and start the server
    def run
      @running = true
      install_signals
      process
    end

    # Set up any signal handlers
    def install_signals
      trap("INT") do
        logger.info("Shutting down device server...")
        @running = false
        EM::stop_event_loop
      end
    end

    # Read from mobd:imei:waiting until it's empty
    # creating new Resque jobs for each IMEI found
    # before sleeping again.
    def process
      while imei = @redis.set_pop("mobd:imei:waiting")
        logger.debug("Dispatching processing for IMEI: #{imei}")
        Resque.enqueue(Worker, imei)
      end

      EM::add_timer(5) { process } if @running
    end

  end

  # Resque worker that, when given an IMEI:
  #  - Locks the imei
  #  - Reads points from the imei's queue until empty
  #  - Waits for a few seconds to catch any stragler points
  #  - Unlocks the imei
  #  - Closes
  class Worker
    include WithActiveRecord

    @queue = :points

    # Resque hook
    def self.perform(imei)
      worker = Worker.new
      worker.process(imei)
    end


    def logger
      DeviceServer.logger
    end


    def initialize
      @redis = Redis.build
    end

    def process(imei)
      # Lock this IMEI
      @redis.set("mobd:lock:#{imei}", Time.now.to_i + 10)

      while point = @redis.pop_head("mobd:imei:#{imei}")
        self.process_point(point)
      end

      # Unlock this IMEI
      @redis.delete("mobd:lock:#{imei}")
    end

    # Given a point from the queue, process it
    def process_point(point)
      with_active_record do
        logger.info(point)

        report = DeviceReport.parse(point)
        tracker = Tracker.find_by_imei_number(report[:imei])

        if tracker
          logger.info("  - tracker #{tracker.id}")
          if tracker.device
            tracker.device.process(report)
          end
        end
      end
    end
  end

  ##
  # Start the Device Server
  ##
  def run
    logger.info("Device Server started")

    EventMachine::run do
      @dispatcher = Dispatcher.new
      @dispatcher.run
    end
  ensure
    logger.info("Device Server stopped")
  end
  module_function :run
end
