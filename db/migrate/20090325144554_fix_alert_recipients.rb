class FixAlertRecipients < ActiveRecord::Migration
  def self.up
    add_column :alert_recipients, :phone_carrier, :string, :limit => 30
    remove_column :alert_recipients, :carrier_id
  end

  def self.down
    add_column :alert_recipients, :carrier_id, :integer
    remove_column :alert_recipients, :phone_carrier
  end
end