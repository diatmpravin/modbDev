class AddMilesToTrip < ActiveRecord::Migration
  def self.up
    add_column :trips, :miles, :integer
    
    # Update any existing trip rows
    Trip.reset_column_information
    Trip.all.each do |trip|
      leg = Leg.first(:conditions => {:trip_id => trip.id})
      if leg
        point = Point.first(:conditions => {:leg_id => leg.id})
        start_miles = point.miles if point
      end
      leg = Leg.last(:conditions => {:trip_id => trip.id})
      if leg
        point = Point.last(:conditions => {:leg_id => leg.id})
        finish_miles = point.miles if point
      end
      
      if start_miles && finish_miles
        trip.miles = finish_miles - start_miles
        trip.save
      end
    end
  end
    
  def self.down
    remove_column :trips, :miles
  end
end
