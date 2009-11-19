class Account < ActiveRecord::Base
  acts_as_tree :order => 'name', :dependent => nil
  
  has_many :devices, :include => :tracker, :dependent => :destroy
  has_many :phones, :dependent => :destroy
  has_many :geofences, :dependent => :destroy
  has_many :landmarks, :dependent => :destroy
  has_many :alert_recipients, :dependent => :destroy
  has_many :tags, :dependent => :destroy
  has_many :users, :dependent => :destroy
  
  validates_presence_of :number
  validates_numericality_of :number
  validates_length_of :name, :maximum => 50
  
  # List accessible attributes here
  attr_accessible :devices, :phones, :geofences, :alert_recipients, :tags, :today,
    :name, :reseller, :can_assign_reseller, :landmarks
  
  def setup?
    self.setup_status == 0
  end
  
  def today
    self[:today] || Time.now.to_date
  end

end
