class RemoveGeofenceAlertsRecipients < ActiveRecord::Migration
  def self.up
    drop_table :geofence_alert_recipients
  end

  def self.down
    create_table :geofence_alert_recipients do |t|
      t.integer :geofence_id
      t.integer :alert_recipient_id
      t.timestamps
    end
  end
end
