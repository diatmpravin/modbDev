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
        acc.devices.each { | d | d.delete }
        acc.trackers.each { | t | t.delete }
        acc.delete

#        acc.trackers.each do | t | 
#          t.destroy
#        end
#        acc.destroy
      end
    end

    def setup 
      clean
      create_test_devices
    end

    def create_test_devices
      account = Account.create( :number => TEST_ACCOUNT, :name => 'Load Testing' )
      
      trackers = []
      DEVICE_COUNT.times do | i |
        tid = IMEI_BASE.to_i + i
        trackers << Tracker.create(:imei_number => tid.to_s, :msisdn_number => tid.to_s, :sim_number => tid.to_s + "0000", :account => account)

        Device.create(:tracker => trackers.last, :imei_number => tid.to_s, :account => account, :name => "Load " + tid.to_s)
      end

      rescue => ex
        puts "failed: " + ex.to_s
    end

  end
end
