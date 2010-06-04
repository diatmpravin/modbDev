class RemovePaidFromInvoices < ActiveRecord::Migration
  def self.up
    remove_column :invoices, :paid
  end

  def self.down
    add_column :invoices, :paid
  end
end
