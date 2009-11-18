class AlertRecipient < ActiveRecord::Base
  include SMSFu
  
  belongs_to :account
  has_many :geofence_alert_recipients, :dependent => :delete_all
  has_many :geofences, :through => :geofence_alert_recipients
  has_many :device_alert_recipients, :dependent => :delete_all
  has_many :devices, :through => :device_alert_recipients
  
  # Return all alert recipients NOT attached to the given object
  named_scope :for, lambda { |object|
    {
      :conditions => [
        "id NOT IN (SELECT alert_recipient_id FROM \
        #{object.class.name.downcase}_alert_recipients WHERE #{object.class.name.downcase}_id = ?)",
        object.id
      ]
    }
  }
  
  # Return alert recipients that match the given parameters
  named_scope :matching, lambda { |hash|
    {
      :conditions => hash[:recipient_type] == EMAIL ?
        ["recipient_type = ? AND email = ?", hash[:recipient_type], hash[:email]] :
        ["recipient_type = ? AND phone_number = ?", hash[:recipient_type], hash[:phone_number]]
    }
  }
  
  class << self
    def valid_carriers
      SMSFu::carriers.map &:first
    end
    def carrier_options
      SMSFu::carriers.sort.collect{ |carrier| [carrier[1]["name"], carrier[0]] }
    end
  end
  
  validates_presence_of :recipient_type
  validates_presence_of :email, :if => :email?
  validates_email_veracity_of :email, :domain_check => false, :if => :email?
  
  validates_presence_of :phone_number, :if => :phone?
  validates_format_of :phone_number, :with => /^\d{10}$/,
    :allow_nil => true, :allow_blank => true, :if => :phone?
  
  validates_presence_of :phone_carrier, :if => :phone?
  validates_inclusion_of :phone_carrier, :in => valid_carriers, :if => :phone? ,
    :allow_nil => true, :allow_blank => true, :message => 'is not a valid carrier'
  
  attr_accessible :recipient_type, :email, :phone_number, :phone_carrier,
    :account, :geofences, :devices
  
  EMAIL = 0
  PHONE = 1
  
  def phone?
    self.recipient_type == PHONE
  end
  
  def email?
    self.recipient_type == EMAIL
  end
  
  def alert(message)
    # TODO: How will alerts decide what timezone they are in?
    # Perhaps alert recipients should be users.
    if email?
      Mailer.deliver_email_alert(self.email,
        "#{ActiveSupport::TimeZone['UTC'].now.to_s(:alerts)} #{message}"
        
      )
    else
      deliver_sms(self.phone_number, self.phone_carrier,
        "#{ActiveSupport::TimeZone['UTC'].now.to_s(:alerts)} #{message}"
      )
    end
  end
  
  def phone_carrier_name
    SMSFu.carriers[self.phone_carrier]['name']
  end
  
  def display_string
    if self.email?
      self.email
    else
      "#{self.phone_number} @ #{self.phone_carrier_name}"
    end
  end
end
