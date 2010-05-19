require 'eventmachine'
require 'redis'

module DeviceServer
  include Logging

  log_to 'device_server'

  class Dispatcher
    def initialize
      @redis = Redis::Client.build
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
      while imei = @redis.spop("mobd:imei:waiting")
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
      @redis = Redis::Client.build
    end

    def process(imei)
      # Lock this IMEI
      @redis.set("mobd:lock:#{imei}", Time.now.to_i + 10)

      while point = @redis.pop_head("mobd:imei:#{imei}")
        p = self.process_point(point)
        # see if we should schedule a leg update
        if imei.match("9999999999") && p && p.leg
          # if not in the queue yet, put it in there
          if !@redis.get("legupdate:#{p.leg_id}")
            @redis.push_tail("legstoupdate", p.leg_id)
          end

          # now push out the update to 5 minutes from now
          @redis.set("legupdate:#{p.leg_id}", Time.now.to_i + 300)
        end
      end


      # TODO this is probably not the place that this code belongs.  Updating of legs
      # shouldn't be triggered by processing of some unrelated random point like it is here

      # now check the schedule time of the next leg to be updated, and if its time is due
      # then update it
      # first get a lock on reading it
      lock = @redis.get("locklegs")
      if !lock || lock.to_i < Time.now.to_i
        @redis.set("locklegs", Time.now.to_i + 5)
        lid = @redis.lindex("legstoupdate", 0)
        if lid
          update_time = @redis.get("legupdate:#{lid}")
          if !update_time || update_time.to_i < Time.now.to_i
            lid = @redis.pop_head("legstoupdate")
            @redis.delete("legupdate:#{lid}")
            leg = Leg.find_by_id(lid)
            if leg
              logger.info("updating leg #{lid}")
              leg.update_precalc_fields
            end
          end
        end
        @redis.delete("locklegs")
      end
    rescue => ex
      Mailer.deliver_exception_thrown ex, "In the DeviceServer Worker, imei #{imei}"
    ensure
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
            return tracker.device.process(report)
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
