class RemovePhones < ActiveRecord::Migration
  def self.up
    drop_table :phones
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
