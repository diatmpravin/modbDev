class AddOccurredAtToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :occurred_at, :datetime
  end

  def self.down
    remove_column :events, :occurred_at, :datetime
  end
end