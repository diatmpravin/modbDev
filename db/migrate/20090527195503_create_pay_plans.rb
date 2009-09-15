class CreatePayPlans < ActiveRecord::Migration
  def self.up
    create_table :pay_plans do |t|
      t.string  :name
      t.string  :description
      t.integer :period
      t.decimal :amount, :precision => 4, :scale => 2, :default => 0.0, :null => false
      t.boolean :public, :default => true
      t.timestamps
    end
  end

  def self.down
    drop_table :pay_plans
  end
end
