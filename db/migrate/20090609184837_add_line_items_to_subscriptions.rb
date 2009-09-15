class AddLineItemsToSubscriptions < ActiveRecord::Migration
  def self.up
    add_column :subscriptions, :line_items, :text
  end

  def self.down
    remove_column :subscriptions, :line_items
  end
end
