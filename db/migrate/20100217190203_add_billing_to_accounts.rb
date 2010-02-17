class AddBillingToAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, :phone_number, :string, :limit => 10
    add_column :accounts, :address1, :string
    add_column :accounts, :address2, :string
    add_column :accounts, :city, :string
    add_column :accounts, :state, :string
    add_column :accounts, :zip, :string
    add_column :accounts, :monthly_unit_price, :decimal, :precision => 6, :scale => 2
  end

  def self.down
    remove_column :accounts, :monthly_unit_price
    remove_column :accounts, :zip
    remove_column :accounts, :state
    remove_column :accounts, :city
    remove_column :accounts, :address2
    remove_column :accounts, :address1
    remove_column :accounts, :phone_number
  end
end
