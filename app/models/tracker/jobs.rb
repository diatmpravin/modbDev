class Tracker < ActiveRecord::Base
  class ConfigureJob
    @queue = :tracker

    def self.perform(tracker_id, options = {})
      tracker = Tracker.find(tracker_id)

      result = tracker.configure!(options.to_options)

      if(result.has_value?(false))
        raise "Tracker::ConfigureJob failed for #{tracker_id} (#{options.inspect}) with #{result.inspect}"
      end
    end
  end
end
