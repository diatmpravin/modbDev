class AddNameToAccount < ActiveRecord::Migration
  def self.up
    add_column :accounts, :name, :string, :limit => 50
  end

  def self.down
    remove_column :accounts, :name
  end
end
