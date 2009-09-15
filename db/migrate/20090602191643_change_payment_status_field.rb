class ChangePaymentStatusField < ActiveRecord::Migration
  def self.up
    change_column :payments, :status, :string, :default => "pending"
  end

  def self.down
    change_column :payments, :status, :integer
  end
end
