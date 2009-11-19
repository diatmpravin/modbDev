class CreateDeviceTags < ActiveRecord::Migration
  def self.up
    create_table :device_tags do |t|
      t.integer :device_id
      t.integer :tag_id
      t.timestamps
    end
  end

  def self.down
    drop_table :device_tags
  end
end
