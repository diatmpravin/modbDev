class Phone < ActiveRecord::Base
  belongs_to :account
  has_many :phone_devices, :dependent => :delete_all
  has_many :devices, :through => :phone_devices
  
  validates_length_of :activation_code, :is => 8
  validates_uniqueness_of :activation_code
  
  before_validation_on_create :generate_activation_code
  
  attr_accessible :name, :account, :phone_devices, :devices, :device_ids
  
  validate :number_of_records
  
  def activate(account)
    if self.account
      false
    else
      self.account = account
      self.devices = account.devices
      generate_moshi_key
      save
    end
  end
  
  def activated?
    !!self.account
  end
  
  def device_ids=(list)
    self.devices = account.devices.find(list)
  end
  
  protected
  def generate_activation_code
    # todo - to be replaced by more suitable logic for production, but for now need a quick
    # way to generate unique alpha numeric codes
    while (true) 
      k = ActiveSupport::SecureRandom.base64.upcase.gsub(/0|O|\+|\/+|=/, '')[0..7]
      if !Phone.find_by_activation_code(k)
        self.activation_code = k
        return
      end
    end
  end
  
  def generate_moshi_key
    self.moshi_key = ActiveSupport::SecureRandom.hex(16)
  end
  
  def number_of_records
    if account_id_changed? &&
        Phone.count(:conditions => {:account_id => account_id}) >= 20
      errors.add_to_base 'Maximum number of phones reached (20 phones)'
    end
  end
end
