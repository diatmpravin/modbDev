class Account < ActiveRecord::Base
  acts_as_tree :order => 'name', :dependent => nil
  
  has_many :devices, :include => :tracker, :dependent => :destroy
  has_many :phones, :dependent => :destroy
  has_many :geofences, :dependent => :destroy
  has_many :landmarks, :dependent => :destroy
  has_many :alert_recipients, :dependent => :destroy
  has_many :tags, :dependent => :destroy
  has_many :users, :dependent => :destroy
  has_many :device_profiles, :order => 'name', :dependent => :destroy
  
  accepts_nested_attributes_for :users
  
  validates_presence_of :name
  validates_presence_of :number
  validates_numericality_of :number
  validates_uniqueness_of :number
  validates_length_of :name, :maximum => 50
  
  before_validation_on_create :generate_number
  
  # List accessible attributes here
  attr_accessible :devices, :phones, :geofences, :alert_recipients, :tags, :today,
    :name, :reseller, :can_assign_reseller, :landmarks, :device_profiles, :users_attributes,
    :address1, :address2, :city, :state, :zip, :monthly_unit_price, :phone

  has_many :groups, :order => "name ASC"

  # Work around bug:
  # https://rails.lighthouseapp.com/projects/8994-ruby-on-rails/tickets/2896-collection_singular_ids-breaks-when-used-with-include
  def device_ids
    Device.find_by_sql(["select d.id from devices d where account_id = ?", self.id]).map(&:id)
  end
  
  def setup?
    self.setup_status == 0
  end
  
  def today
    self[:today] || Time.now.to_date
  end
  
  protected
  
  def generate_number
    self.number = Account.maximum(:number) + 1
  end

end
