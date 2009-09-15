class CreateAlertRecipients < ActiveRecord::Migration
  def self.up
    create_table :alert_recipients do |t|
      t.integer :account_id
      t.integer :recipient_type
      t.string :email, :limit => 50
      t.string :phone_number, :limit => 10
      t.integer :carrier_id
      t.timestamps
    end
  end

  def self.down
    drop_table :alert_recipients
  end
end
