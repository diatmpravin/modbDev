class AddFieldsToTrip < ActiveRecord::Migration
  def self.up
    add_column :trips, :start, :datetime
    add_column :trips, :finish, :datetime
    
    # Update any existing trip rows
    Trip.reset_column_information
    Trip.all.each do |trip|
      leg = Leg.first(:conditions => {:trip_id => trip.id})
      if leg
        point = Point.first(:conditions => {:leg_id => leg.id})
        if point
          trip.start = point.occurred_at
        end
      end
      leg = Leg.last(:conditions => {:trip_id => trip.id})
      if leg
        point = Point.last(:conditions => {:leg_id => leg.id})
        if point
          trip.finish = point.occurred_at
        end
      end
      trip.save
    end
  end

  def self.down
    remove_column :trips, :start
    remove_column :trips, :finish
  end
end
