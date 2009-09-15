class AddFieldsToPoints < ActiveRecord::Migration
  def self.up
    add_column :points, :mpg, :decimal, :precision => 4, :scale => 1
    add_column :points, :battery, :decimal, :precision => 3, :scale => 1
    add_column :points, :signal, :integer
    add_column :points, :locked, :boolean
  end

  def self.down
    remove_column :points, :mpg
    remove_column :points, :battery
    remove_column :points, :signal
    remove_column :points, :locked
  end
end