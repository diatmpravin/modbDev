class AddDeleteFlagToDevices < ActiveRecord::Migration
  def self.up
    add_column :devices, :to_be_deleted, :boolean
  end

  def self.down
    remove_column :devices, :to_be_deleted
  end
end
