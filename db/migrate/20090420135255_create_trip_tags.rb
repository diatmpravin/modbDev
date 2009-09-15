class CreateTripTags < ActiveRecord::Migration
  def self.up
    create_table :trip_tags do |t|
      t.integer :trip_id
      t.integer :tag_id
      t.timestamps
    end
  end

  def self.down
    drop_table :trip_tags
  end
end