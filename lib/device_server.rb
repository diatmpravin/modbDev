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
      Thread.new { process_trips() }
      process
    end

    def process_trips
      while @running
        sleep(3)

        # now check for leg updates that are due
        # first get a lock on reading it
        lock = @redis.get("locklegs")
        if !lock || lock.to_i < Time.now.to_i
          @redis.set("locklegs", Time.now.to_i + 5)
          try_again = true
          while try_again && @running
            try_again = false
            # grab the first one and see if it is due to be updated
            lid = @redis.pop_head("legstoupdate")
            if lid
              update_time = @redis.get("legupdate:#{lid}")
              if !update_time || update_time.to_i < Time.now.to_i
                @redis.delete("legupdate:#{lid}")
                Resque.enqueue(Worker, lid)
                # maybe another one is due, so try the loop again
                try_again = true
              else
                # add it back in to the end of the list
                @redis.push_tail("legstoupdate", lid)
              end
            end
          end
          @redis.delete("locklegs")
        end
      end
    rescue => ex
      Mailer.deliver_exception_thrown ex, "In the DeviceServer trip thread"
      if @running
        Thread.new { process_trips() }
      end
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
      while @running
        while imei = @redis.spop("mobd:imei:waiting")
          logger.debug("Dispatching processing for IMEI: #{imei}")
          PointProcessor.new.process(imei)
        end
        sleep(1)
      end

    rescue
      EM::add_timer(5) { process } if @running
    end

  end


  # point processor, when given an imei:
  #  - Reads points from the imei's queue until empty
  #  - creates points in the db
  #  - schedules the leg to be updated 5 minutes in the future
  class PointProcessor
    include WithActiveRecord
 
    def initialize
      @redis = Redis::Client.build
    end

    def logger
      DeviceServer.logger
    end

    def process(imei)
      # Lock this IMEI
      @redis.set("mobd:lock:#{imei}", Time.now.to_i + 10)

      while point = @redis.pop_head("mobd:imei:#{imei}")
        p = self.process_point(point)
        # see if we should schedule a leg update
        if p && p.leg
          # if not in the queue yet, put it in there
          if !@redis.get("legupdate:#{p.leg_id}")
            @redis.push_tail("legstoupdate", p.leg_id)
          end

          # now push out the leg update to 10 minutes from now          
          @redis.set("legupdate:#{p.leg_id}", Time.now.to_i + 600)
        end
      end
    rescue => ex
      Mailer.deliver_exception_thrown ex, "In the DeviceServer PointProcessor, imei #{imei}"
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

  # Resque worker that, when given leg_id:
  #  - calls update_precalc_fields on that leg
  class Worker
    include WithActiveRecord

    @queue = :points

    # Resque hook
    def self.perform(leg_id)
      worker = Worker.new
      worker.process(leg_id)
    end

    def logger
      DeviceServer.logger
    end

    def initialize
      @redis = Redis::Client.build
    end

    def process(leg_id)
      leg = Leg.find_by_id(leg_id)
      if leg
        logger.info("updating leg #{leg_id}")
        leg.update_precalc_fields
      end
    rescue => ex
      puts "Exception: " + ex.inspect
      Mailer.deliver_exception_thrown ex, "In the DeviceServer Worker, leg #{leg_id}"
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
