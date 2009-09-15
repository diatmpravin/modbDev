class CreateSubscriptions < ActiveRecord::Migration
  def self.up
    create_table :subscriptions do |t|
      t.integer :account_id

      t.integer :pay_plan_id

      t.string  :cc_last_four, :limit => 4
      t.string  :expr_year, :limit => 4
      t.string  :expr_month, :limit => 2
      t.string  :card_type

      t.string  :reference, :limit => 32

      t.string  :name
      t.string  :address1
      t.string  :address2
      t.string  :city
      t.string  :state
      t.string  :zip
      t.string  :country, :limit => 2

      t.string  :state

      t.datetime :deleted_at

      t.timestamps
    end
  end

  def self.down
    drop_table :subscriptions
  end
end
