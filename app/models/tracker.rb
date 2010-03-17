class Tracker < ActiveRecord::Base

  concerned_with :jobs

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

  concerned_with :sphinx
  
  def status_text
    TEXT[status] || 'Unknown'
  end
  # Set the speed threshold in mph, 0 will disable the threshold.
  # Speed must be >= 20 mph and in increments of 5 mph
  def set_speed_threshold!(speed)
    speed = speed.to_i

    if(speed != 0 && speed < 20)
      raise ArgumentError, "speed must be >= 20 or 0 to disable"
    end

    if(speed % 5 != 0)
      raise ArgumentError, "speed must be in 5 mph increments"
    end

    !!self.send!("+XT:3004,#{speed}")
  end

  # Set the RPM threshold for aggressive driving alerts, 0 will disable
  # the threshold. Minimum allowed value is 100 rpm.
  def set_rpm_threshold!(rpm)
    rpm = rpm.to_i

    if(rpm != 0 && rpm < 100)
      raise ArgumentError, "rpm must be >= 100 or 0 to disable"
    end

    !!self.send!("+XT:3005,#{rpm}")
  end

  # Set the idle time threshold (in minutes) for idle alerts, minimum is 10 minutes
  # and must be in increments of 5 minuts.
  def set_idle_threshold!(time)
    time = time.to_i

    if time != 0 && time < 10
      raise ArgumentError, "time must be >= 10 minutes"
    end

    if time % 5 != 0
      raise ArgumentError, "time must be in 5 minute increments"
    end

    !!self.send!("+XT:3013,#{time}")
  end

  def configure!(options = {})
    options.symbolize_keys!

    {}.tap do |success|
      if(options[:speed])
        success[:speed] = set_speed_threshold!(options[:speed])
      end

      if(options[:rpm])
        success[:rpm] = set_rpm_threshold!(options[:rpm])
      end

      if (options[:idle])
        success[:idle] = set_idle_threshold!(options[:idle])
      end
    end
  end

  def async_configure(options = {})
    if(!options.blank?)
      Resque.enqueue(ConfigureJob, self.id, options)
    end
  end

  # TODO: Need to better handle errors
  def send!(message)
    if(self.msisdn_number.blank?)
      if(info = get_sim_info)
        self.update_attribute(:msisdn_number, response[:msisdn])
      end
    end

    JasperSmsGateway.send(self.msisdn_number, message)
  end

  def get_sim_info
    Jasper.new.get_sim_info(self.sim_number)
  end

  def get_settings!
    send!('+XT:3050')
  end
end
