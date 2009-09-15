class CreateTrips < ActiveRecord::Migration
  def self.up
    create_table :trips do |t|
      t.string :name, :limit => 30
      t.timestamps
    end
  end

  def self.down
    drop_table :trips
  end
end
