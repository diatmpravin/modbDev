class CreateDeviceProfiles < ActiveRecord::Migration
  def self.up
    create_table :device_profiles do |t|
      t.integer :account_id
      t.boolean :alert_on_speed
      t.integer :speed_threshold
      t.boolean :alert_on_aggressive
      t.integer :rpm_threshold
      t.boolean :alert_on_idle
      t.integer :idle_threshold
      t.boolean :alert_on_after_hours
      t.integer :after_hours_start
      t.integer :after_hours_end
      t.string :time_zone
      t.boolean :detect_pitstops
      t.integer :pitstop_threshold
      t.timestamps
    end
  end

  def self.down
    drop_table :device_profiles
  end
end
