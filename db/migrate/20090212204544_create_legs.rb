class CreateLegs < ActiveRecord::Migration
  def self.up
    create_table :legs do |t|
      t.integer :trip_id
      t.timestamps
    end
  end

  def self.down
    drop_table :legs
  end
end
