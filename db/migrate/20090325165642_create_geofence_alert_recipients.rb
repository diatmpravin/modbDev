class CreateGeofenceAlertRecipients < ActiveRecord::Migration
  def self.up
    create_table :geofence_alert_recipients do |t|
      t.integer :geofence_id
      t.integer :alert_recipient_id
      t.timestamps
    end
  end

  def self.down
    drop_table :geofence_alert_recipients
  end
end
