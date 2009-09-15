class CreateDeviceAlertRecipients < ActiveRecord::Migration
  def self.up
    create_table :device_alert_recipients do |t|
      t.integer :device_id
      t.integer :alert_recipient_id
      t.timestamps
    end
  end

  def self.down
    drop_table :device_alert_recipients
  end
end