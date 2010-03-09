class AddReportGradingToGroups < ActiveRecord::Migration
  def self.up
    add_column :groups, :grading, :text
  end

  def self.down
    remove_column :groups, :grading
  end
end
