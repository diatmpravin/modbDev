class Invoice < ActiveRecord::Base

  belongs_to :account

  validates_presence_of :account

  def paid?
    self.amount_paid >= self.amount
  end
end
