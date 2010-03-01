class AddDeltaToLandmarks < ActiveRecord::Migration
  def self.up
    add_column :landmarks, :delta, :boolean, :default => true, :null => false
  end

  def self.down
    remove_column :landmarks, :delta
  end
end
