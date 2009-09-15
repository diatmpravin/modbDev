class AddCancellationDateToSubscriptions < ActiveRecord::Migration
  def self.up
    add_column :subscriptions, :cancellation_date, :date
  end

  def self.down
    remove_column :subscriptions, :cancellation_date
  end
end
