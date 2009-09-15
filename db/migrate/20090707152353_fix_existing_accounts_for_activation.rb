class FixExistingAccountsForActivation < ActiveRecord::Migration
  def self.up
    Account.all.each { |a| 
      a.activated_at = Time.now if a.activated_at.nil?
      a.save 
    }
  end

  def self.down
  end
end
