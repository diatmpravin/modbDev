class DropSubscriptionTables < ActiveRecord::Migration
  def self.up
    drop_table :subscriptions
    drop_table :payments
    drop_table :pay_plans
    drop_table :payment_transactions
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end