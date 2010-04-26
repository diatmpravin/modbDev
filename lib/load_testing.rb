require 'eventmachine'

module LoadTesting

  class LoadTestSetup
    TEST_ACCOUNT = 9999
    DEVICE_COUNT = 10

    IMEI_BASE = "999999999900000"

    def initialize
    end

    def cleanup
      acc = Account.find_by_name('Load Testing')
      if acc

# TODO change all of the "delete" calls below to "destroy"

        # delete the trackers
        acc.trackers.each { | t | t.delete }

        # Now delete the points, legs, and trips
        acc.devices.each do | d |
          d.trips.each do | t |
            t.legs.each do | l | 
              l.points.each do | p |
                p.events.delete_all
                p.delete
              end
              l.delete
            end
            t.delete
          end
          d.delete
        end

        # Now destroy the account, which deletes devices as well
        acc.delete
      end

      rescue => ex
        puts ex.to_s
    end

    def stats
      acc = Account.find_by_name('Load Testing')
      if acc
        sum = 0
        acc.devices.each { | d | sum += d.points.size }

        puts "Total points: #{sum}"
      end
    end

    def setup(num_devices = DEVICE_COUNT)
      clean
      create_test_devices(num_devices)
    end

    def create_test_devices(num_devices)
      account = Account.create( :number => TEST_ACCOUNT, :name => 'Load Testing' )
      puts "created account #{account.name}"
      
      trackers = []
      num_devices.times do | i |
        tid = IMEI_BASE.to_i + i
        trackers << Tracker.create!(:imei_number => tid.to_s, :msisdn_number => '', :sim_number => tid.to_s + "0000", :account => account)

        puts "created tracker #{trackers.last.imei_number}"
        Device.create!(:tracker => trackers.last, :imei_number => tid.to_s, :account => account, :name => "Load " + tid.to_s)
        puts "created device #{Device.last.name}"
      end

      rescue => ex
        puts "failed: " + ex.to_s
        clean
    end

  end
end
