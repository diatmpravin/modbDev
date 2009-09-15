class PhoneDevice < ActiveRecord::Base
  belongs_to :phone
  belongs_to :device
  
  attr_accessible :phone, :device
end