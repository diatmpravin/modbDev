class FixPrecisionOnPayPlans < ActiveRecord::Migration
  def self.up
    change_column :pay_plans, :amount, :decimal, :precision => 6, :scale => 2, :default => 0.0, :null => false
  end

  def self.down
  end
end
