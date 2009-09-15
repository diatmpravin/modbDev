class CreatePayments < ActiveRecord::Migration
  def self.up
    create_table :payments do |t|
      t.integer  "subscription_id"
      t.integer  "payment_type"
      t.integer  "status", :default => 0
      t.decimal  "subtotal", :precision => 8, :scale => 2, :default => 0.0, :null => false
      t.decimal  "state_tax", :precision => 8, :scale => 2, :default => 0.0, :null => false
      t.decimal  "total", :precision => 8, :scale => 2, :default => 0.0, :null => false
      t.string   "state", :limit => 2
      t.string   "comment", :limit => 50
      t.text     "line_items"
      t.datetime "payment_date"
      t.timestamps
    end
  end

  def self.down
    drop_table :payments
  end
end
