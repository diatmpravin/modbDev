class ChangeDefaultOnPointMpg < ActiveRecord::Migration
  def self.up
    change_column :points, :mpg, :decimal, :precision => 4, :scale => 1, :default => 0
  end

  def self.down
    change_column :points, :mpg, :decimal, :precision => 4, :scale => 1
  end
end
