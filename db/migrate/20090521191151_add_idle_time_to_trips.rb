class AddIdleTimeToTrips < ActiveRecord::Migration
  def self.up
    add_column :trips, :idle_time, :integer, :default => 0
    
    # Update any existing trip rows - time consuming!
    Trip.reset_column_information
    Trip.all.each do |trip|
      sum = 0
      
      Leg.all(:conditions => {:trip_id => trip.id}).each do |leg|
        points = Point.all(:conditions => {:leg_id => leg.id})
        points[0..-2].each_index do |i|
          if points[i].speed == 0
            sum += points[i+1].occurred_at - points[i].occurred_at
          end
        end
      end
      
      trip.idle_time = sum
      trip.save
    end
  end

  def self.down
    remove_column :trips, :idle_time
  end
end