class PrecalculatePointLegAndTripData < ActiveRecord::Migration
  def self.up
    # Mimic the behavior of the "precalculate field" logic that was added
    # to the point, leg, and trip models. This should have been part of
    # the original migration, but better late than never.
    
    # Handle points
    Device.all.each do |device|
      points = Point.all(:conditions => {:device_id => device.id}, :order => 'occurred_at')
      
      points[0..-2].each_index do |i|
        duration = points[i+1].occurred_at - points[i].occurred_at
        Point.update_all({:duration => duration}, {:id => points[i].id})
      end
    end
    
    # Handle legs
    Leg.all.each do |leg|
      points = Point.all(:conditions => {:leg_id => leg.id}, :order => 'occurred_at')
      
      # Validate ALL points. If any have no device, exit.
      if points.select {|p| p.device_id.nil?}.length > 0
        next
      end
      
      first_point = points.first
      last_point = points.last
      
      if first_point && last_point
        duration = last_point.occurred_at - first_point.occurred_at
        
        miles = last_point.miles - first_point.miles
        miles += 10000 if miles < 0
        
        idle_time = Point.sum(:duration, :conditions => [
          "speed = 0 AND leg_id = ? AND occurred_at < ?",
          leg.id,
          last_point.occurred_at
        ])
        
        if duration <= 0
          average_mpg = first_point.mpg
        else
          sum = 0
          points[0..-2].each_index do |i|
            sum += points[i].duration * (points[i+1].mpg + points[i].mpg) / 2
          end
          
          average_mpg = sum / duration
        end
        
        values = {
          :start => first_point.occurred_at,
          :finish => last_point.occurred_at,
          :miles => miles,
          :idle_time => idle_time,
          :average_mpg => average_mpg
        }
      
        Leg.update_all(values, {:id => leg.id})
      end
    end
    
    # Handle trips
    Trip.all.each do |trip|
      legs = Leg.all(:conditions => {:trip_id => trip.id}, :order => 'start')
      
      if legs.length < 2
        average_mpg = legs.first.average_mpg
      else
        sum = 0
        in_leg_duration = 0
        legs.each do |leg|
          sum += (leg.finish - leg.start) * leg.average_mpg
          in_leg_duration += (leg.finish - leg.start)
        end
        
        average_mpg = sum / in_leg_duration
      end
      
      values = {
        :start => legs.first.start,
        :finish => legs.last.finish,
        :miles => legs.inject(0) {|sum, leg| sum += leg.miles},
        :idle_time => legs.inject(0) {|sum, leg| sum += leg.idle_time},
        :average_mpg => average_mpg
      }
      
      Trip.update_all(values, {:id => trip.id})
    end
  end

  def self.down
    # Nothing
  end
end
