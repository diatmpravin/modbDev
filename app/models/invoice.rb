class Invoice < ActiveRecord::Base

  belongs_to :account

  validates_presence_of :account
end
