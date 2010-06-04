class CreateInvoices < ActiveRecord::Migration
  def self.up
    create_table :invoices do |t|
      t.integer :account_id
      t.decimal :amount, :precision => 6, :scale => 2
      t.date :due_on
      t.integer :number_of_units
      t.boolean :paid

      t.timestamps
    end
  end

  def self.down
    drop_table :invoices
  end
end
