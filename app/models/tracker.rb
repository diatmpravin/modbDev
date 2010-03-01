class Tracker < ActiveRecord::Base
  belongs_to :account
  has_one :device, :dependent => :nullify
  
  UNKNOWN = 0
  INVENTORY = 1
  ACTIVE = 2
  
  TEXT = {
    UNKNOWN => 'Not Tested / Unknown',
    INVENTORY => 'Inventory',
    ACTIVE => 'Active'
  }
  
  validates_presence_of :account
  validates_format_of :imei_number, :with => /^\d{15}$/, :message => 'must be 15 digits',
    :allow_nil => false, :allow_blank => false
  validates_uniqueness_of :imei_number
  validates_format_of :sim_number, :with => /^\d{19,20}$/, :message => 'must be 19 or 20 digits',
    :allow_nil => true, :allow_blank => true
  validates_format_of :msisdn_number, :with => /^\d{15}$/, :message => 'must be 15 digits',
    :allow_nil => true, :allow_blank => true
  
  named_scope :unknown, :conditions => {:status => UNKNOWN}
  named_scope :inventory, :conditions => {:status => INVENTORY}
  named_scope :active, :conditions => {:status => ACTIVE}
  
  attr_accessible :imei_number, :sim_number, :msisdn_number, :status, :account
  
  def status_text
    TEXT[status] || 'Unknown'
  end
end