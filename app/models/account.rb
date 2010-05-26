class Account < ActiveRecord::Base
  has_many :devices, :include => :tracker, :dependent => :destroy
  has_many :geofences, :dependent => :destroy
  has_many :landmarks, :dependent => :destroy
  has_many :alert_recipients, :dependent => :destroy
  has_many :tags, :dependent => :destroy
  has_many :users, :dependent => :destroy
  has_many :invoices, :dependent => :destroy
  has_many :device_profiles, :order => 'name', :dependent => :destroy
  has_many :device_groups, :order => 'name ASC', :dependent => :destroy
  has_many :trackers, :dependent => :nullify
  
  accepts_nested_attributes_for :users
  
  concerned_with :sphinx
  
  validates_presence_of :name
  validates_presence_of :number
  validates_numericality_of :number
  validates_uniqueness_of :number
  validates_length_of :name, :maximum => 50
  validates_format_of :phone_number, :with => /^\d{10}$/,
    :allow_nil => true, :allow_blank => true, :message => 'is not a valid phone number'
  
  before_validation_on_create :generate_number
  
  # List accessible attributes here
  attr_accessible :devices, :geofences, :alert_recipients, :tags, :today,
    :name, :reseller, :can_assign_reseller, :landmarks, :device_profiles, :users_attributes,
    :address1, :address2, :city, :state, :zip, :monthly_unit_price, :phone_number,
    :device_groups

  # This line must appear later than the above attr_accessible line
  acts_as_nested_set :order => 'name', :dependent => nil

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
  
  def generate_invoice(generate_on)

    # due on is end of month for current running date
    due_on = generate_on.end_of_month

    # start of period should be the first of the month
    period_start = generate_on.beginning_of_month
    number_of_units = self.trackers.count
    number = (self.invoices.maximum(:number) || 1000) + 1

    # multiply number of trackers by price_per_unit
    amount = number_of_units * (self.monthly_unit_price || 0)

    #TODO - generate an exception and send an email for no monthly unit price?
    # new exception method to send to reseller instead of devs.

    #TODO - generate an email when a new invoice is successfully created
    # send it to anyone on the account with billing

    invoice = self.invoices.build( {
      :generated_on => generate_on,
      :due_on => due_on,
      :period_start => period_start,
      :number_of_units => number_of_units,
      :number => number,
      :amount => amount,
      :paid => false
    });

    invoice.save

    invoice
  end

  protected
  
  def generate_number
   self.number = Account.maximum(:number) + 1
  end

end
