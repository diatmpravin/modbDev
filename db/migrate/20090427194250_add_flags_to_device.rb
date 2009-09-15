class AddFlagsToDevice < ActiveRecord::Migration
  def self.up
    add_column :devices, :alert_on_acceleration, :boolean, :default => false
    add_column :devices, :alert_on_deceleration, :boolean, :default => false
  end

  def self.down
    remove_column :devices, :alert_on_acceleration
    remove_column :devices, :alert_on_deceleration
  end
end