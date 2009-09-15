class CreatePaymentTransactions < ActiveRecord::Migration
  def self.up
    create_table :payment_transactions do |t|
      t.integer  "subscription_id"
      t.integer  "payment_id"
      t.decimal  "amount", :precision => 8, :scale => 2, :default => 0.0, :null => false
      t.boolean  "success"
      t.string   "reference"
      t.string   "message"
      t.string   "action"
      t.timestamps
    end
  end

  def self.down
    drop_table :payment_transactions
  end
end
