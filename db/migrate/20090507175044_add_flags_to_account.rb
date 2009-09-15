class AddFlagsToAccount < ActiveRecord::Migration
  def self.up
    add_column :accounts, :accept_terms, :boolean, :default => false
    add_column :accounts, :accept_offers, :boolean, :default => false
  end

  def self.down
    remove_column :accounts, :accept_terms
    remove_column :accounts, :accept_offers
  end
end