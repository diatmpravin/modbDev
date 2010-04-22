require 'eventmachine'

module LoadTesting

  class LoadTestSetup
    TEST_ACCOUNT = 9999
    DEVICE_COUNT = 10

    IMEI_BASE = "999999999900000"

    def initialize
    end

    def clean 
      acc = Account.find_by_name('Load Testing')
      if acc
#        acc.trackers.delete_all
#
#        acc.devices.each { | d | 
#          d.points.delete_all
#          d.trips.each { | t | 
#            t.legs.delete_all 
#            t.delete 
#          }
#          d.delete
#        }
#        acc.delete

# TODO change all of the "delete" calls below to "destroy"

        # delete the trackers
        acc.trackers.each { | t | t.destroy }

        # Now delete the points, legs, and trips
        acc.devices.each do | d |
          d.trips.each do | t |
            t.legs.each do | l | 
              l.points.each do | p |
                p.events.each { | e | e.destroy }
                p.destroy
              end
              l.destroy
            end
            t.destroy
          end
          d.destroy
        end

        # Now destroy the account, which deletes devices as well
        acc.destroy
      end

      rescue => ex
        puts ex.to_s
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
