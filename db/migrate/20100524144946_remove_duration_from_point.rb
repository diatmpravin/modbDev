class RemoveDurationFromPoint < ActiveRecord::Migration
  def self.up
    remove_column :points, :duration
  end

  def self.down
    add_column :points, :duration, :integer
  end
end
