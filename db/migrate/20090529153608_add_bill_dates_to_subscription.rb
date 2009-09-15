class AddBillDatesToSubscription < ActiveRecord::Migration
  def self.up
    add_column :subscriptions, :next_bill_date, :date
    add_column :subscriptions, :first_bill_date, :date
  end

  def self.down
    remove_column :subscriptions, :next_bill_date, :date
    remove_column :subscriptions, :first_bill_date, :date
  end
end
