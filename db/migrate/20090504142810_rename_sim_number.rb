class RenameSimNumber < ActiveRecord::Migration
  def self.up
    rename_column :devices, :sim_number, :imei_number
  end

  def self.down
    rename_column :devices, :imei_number, :sim_number
  end
end