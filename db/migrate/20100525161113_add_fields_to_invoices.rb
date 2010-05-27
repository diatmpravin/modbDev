class AddFieldsToInvoices < ActiveRecord::Migration
  def self.up
    add_column :invoices, :number, :integer
    add_column :invoices, :generated_on, :date
    add_column :invoices, :period_start, :date
  end

  def self.down
    remove_column :invoices, :number
    remove_column :invoices, :generated_on
    remove_column :invoices, :period_start
  end
end
