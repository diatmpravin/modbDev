class AddLegIdToPoints < ActiveRecord::Migration
  def self.up
    add_column :points, :leg_id, :integer
  end

  def self.down
    remove_column :points, :leg_id
  end
end
