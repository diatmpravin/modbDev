class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.integer :point_id
      t.integer :event_type
      t.string :geofence_name
      t.integer :speed_threshold
      t.timestamps
    end
  end
  
  def self.down
    drop_table :events
  end
end