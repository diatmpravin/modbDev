class AddAverageMpgToTrips < ActiveRecord::Migration
  def self.up
    add_column :trips, :average_mpg, :decimal, :precision => 4, :scale => 1, :default => 0
    
    # Pre-populate all existing trips with average miles per gallon
    Trip.reset_column_information
    Trip.all.each do |trip|
      sum = 0
      duration = trip.finish - trip.start
      
      if duration > 0
        Leg.all(:conditions => {:trip_id => trip.id}).each do |leg|
          points = Point.all(:conditions => {:leg_id => leg.id})
          
          points[0..-2].each_index do |i|
            sum += (points[i+1].occurred_at - points[i].occurred_at) * (points[i+1].mpg + points[i+1].mpg) / 2
          end
        end
        
        trip.average_mpg = sum / duration
        trip.save
      end
    end
  end

  def self.down
    remove_column :trips, :average_mpg
  end
end
