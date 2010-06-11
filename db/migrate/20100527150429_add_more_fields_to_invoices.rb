class AddMoreFieldsToInvoices < ActiveRecord::Migration
  def self.up
    add_column :invoices, :name, :string
    add_column :invoices, :amount_paid, :decimal, :precision => 6, :scale => 2
  end

  def self.down
    remove_column :invoices, :name
    remove_column :invoices, :amount_paid
  end
end
