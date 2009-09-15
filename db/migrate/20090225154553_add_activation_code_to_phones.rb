class AddActivationCodeToPhones < ActiveRecord::Migration
  def self.up
    add_column :phones, :activation_code, :string, :limit => 8
  end

  def self.down
    remove_column :phones, :activation_code
  end
end
