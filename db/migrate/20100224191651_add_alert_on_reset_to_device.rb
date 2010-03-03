class AddAlertOnResetToDevice < ActiveRecord::Migration
  def self.up
    add_column :devices, :alert_on_reset, :boolean, :default => false
  end

  def self.down
    remove_column :devices, :alert_on_reset
  end
end
