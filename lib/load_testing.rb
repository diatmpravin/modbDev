require 'eventmachine'

module LoadTesting

    TEST_ACCOUNT = 9999
    DEVICE_COUNT = 10

    IMEI_BASE = "999999999900000"

    def cleanup
      # first delete the points
      delete_points
     
      # now delete the trackers and devices
      acc = Account.find_by_name('Load Testing')
      if acc
# TODO change all of the "delete" calls below to "destroy"

        acc.trackers.each { | t | t.delete }
        acc.devices.each { | d | d.delete }

        # Now delete the account
        acc.delete
      end

      rescue => ex
        puts ex.to_s
    end

    def delete_points
      acc = Account.find_by_name('Load Testing')
      if acc
# TODO change all of the "delete" calls below to "destroy"

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
        end
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
      cleanup
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
        cleanup
    end

    module_function :setup
    module_function :cleanup
    module_function :stats
    module_function :delete_points
    module_function :create_test_devices
end
