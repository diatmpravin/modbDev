class NextPayPlanOnSubscriptions < ActiveRecord::Migration
  def self.up
    add_column :subscriptions, :next_pay_plan_id, :integer
  end

  def self.down
    remove_column :subscriptions, :next_pay_plan_id
  end
end
