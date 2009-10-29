class AddDurationToPoints < ActiveRecord::Migration
  def self.up
    add_column :points, :duration, :integer
  end

  def self.down
    remove_column :points, :duration
  end
end
