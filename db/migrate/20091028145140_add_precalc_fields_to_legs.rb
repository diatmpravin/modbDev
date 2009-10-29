class AddPrecalcFieldsToLegs < ActiveRecord::Migration
  def self.up
    add_column :legs, :start, :datetime
    add_column :legs, :finish, :datetime
    add_column :legs, :miles, :integer, :default => 0
    add_column :legs, :idle_time, :integer, :default => 0
    add_column :legs, :average_mpg, :decimal, :precision => 4, :scale => 1, :default => 0
    
    change_column :trips, :miles, :integer, :default => 0
  end

  def self.down
    remove_column :legs, :start
    remove_column :legs, :finish
    remove_column :legs, :miles
    remove_column :legs, :idle_time
    remove_column :legs, :average_mpg
    
    change_column :trips, :miles, :integer
  end
end
