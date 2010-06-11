class AddTaxInfoFieldsToAccount < ActiveRecord::Migration
  def self.up
    add_column :accounts, :taxpayer_id, :string
    add_column :accounts, :tax_exempt, :boolean
  end

  def self.down
    remove_column :accounts, :taxpayer_id
    remove_column :accounts, :tax_exempt
  end
end
