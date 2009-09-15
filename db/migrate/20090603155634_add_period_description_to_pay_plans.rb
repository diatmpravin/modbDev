class AddPeriodDescriptionToPayPlans < ActiveRecord::Migration
  def self.up
    add_column :pay_plans, :period_description, :string
  end

  def self.down
    remove_column :pay_plans, :period_description
  end
end
