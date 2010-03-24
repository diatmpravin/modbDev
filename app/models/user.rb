require 'digest/sha1'
class User < ActiveRecord::Base
  belongs_to :account
  
  belongs_to :device_group
  
  ##
  # Concerns
  ##
  concerned_with :sphinx
  
  # Virtual attribute for the unencrypted password
  attr_accessor :password
  
  # Virtual attribute for current password
  attr_accessor :current_password
  
  # Virtual attribute, set when we require the user to enter current password
  attr_accessor :require_current_password
  
  # Validating account causes account create to fail
  #validates_presence_of     :account
  validates_presence_of     :login, :name, :email
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 4..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_length_of       :login,    :within => 3..30,
    :allow_nil => true, :allow_blank => true
  validates_length_of       :name,     :within => 1..30,
    :allow_nil => true, :allow_blank => true
  validates_length_of       :email,    :within => 3..50,
    :allow_nil => true, :allow_blank => true
  validates_uniqueness_of   :login, :case_sensitive => false, :scope => :account_id
  validate_on_update        :current_password_matches
  validates_inclusion_of    :time_zone, :in => ActiveSupport::TimeZone.us_zones.map {|z| z.name}
  validates_email_veracity_of :email, :domain_check => false, :message => 'is not a valid e-mail address'
  
  # List accessible attributes here
  attr_accessible :login, :email, :password, :password_confirmation,
    :account, :current_password, :roles, :name, :time_zone,
    :device_group, :device_group_id
  
  before_validation_on_create :lock_password
  before_save                 :encrypt_password
  after_create                :send_set_password
  
  # Allow device_group_id=, but enforce account ownership and group type
  def device_group_id=(value)
    self.device_group = value.blank? ? nil : account.device_groups.find(value)
  end
  
  class Role
    # Defined as bit positions
    ADMIN    = 0
    RESELLER = 1
    BILLING  = 2
    USERS    = 3
    FLEET    = 4
    
    ROLES = [
      ADMIN, RESELLER, BILLING, USERS, FLEET
    ].freeze
  end
  
  def roles
    list = self[:roles] || 0
    
    # If the user has ADMIN role, they have ALL roles
    if (list >> Role::ADMIN) & 1 == 1
      Role::ROLES
    else
      Role::ROLES.select {|r|
        (list >> r) & 1 == 1
      }
    end
  end
  
  def roles=(array)
    list = Role::ROLES & array.map(&:to_i)
    self[:roles] = list.map {|r| 1 << r}.inject(&:|)
  end
  
  def has_role?(role)
    roles.include?(role)
  end
  
  # These are the roles this user is allowed to assign to others
  def assignable_roles
    if account.reseller?
      roles - [User::Role::ADMIN]
    else
      roles - [User::Role::ADMIN, User::Role::RESELLER]
    end
  end
  
  # Is this user allowed to edit/modify another user on the Users page?
  # Is this user allowed to edit/modify another vehicle on the Vehicles page?
  def can_edit?(object)
    if object.is_a?(User)
      self != object
    elsif object.is_a?(Device)
      device_group.nil? ||
        device_group.self_and_descendants.all(
          :joins => :devices,
          :conditions => {:devices => {:id => object.id}}
        ).any?
    else
      true
    end
  end
  
  def devices
    device_group.nil? ? account.devices : account.devices.all(:conditions => {:group_id => device_group.self_and_descendants.map(&:id)})
    #account.devices.all(:joins => :device_group, :conditions => {:group => {:lft => device_group.lft..device_group.rgt }})
  end

  def groups
    device_group.nil? ? account.groups : device_group.self_and_descendants
  end
  
  def group_name
    device_group.nil? ? 'All' : device_group.name
  end
  
  def zone
    ActiveSupport::TimeZone[self[:time_zone]]
  end
  
  # Authenticates a user by their login name and unencrypted password. Returns a user or nil.
  # Only users linked to the given account can be returned.
  def self.authenticate(account, login, password)
    u = find_by_account_id_and_login(account.id, login) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    remember_me_for 2.weeks
  end

  def remember_me_for(time)
    remember_me_until time.from_now.utc
  end

  def remember_me_until(time)
    self.remember_token_expires_at = time
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end
  
  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end
  
  def forgot_password
    generate_password_reset_code
    save(false)
    
    Mailer.deliver_forgotten_password(self)
  end

  def lock_password
    self.crypted_password = "!!#{self.crypted_password}"
  end

  def reset_password(new_password, new_password_confirmation)
    self.password_reset_code = nil
    self.password = new_password
    self.password_confirmation = new_password_confirmation
  end

  def send_set_password
    generate_password_reset_code
    save(false)
    
    Mailer.deliver_set_password(self)
  end
  
  protected
  def encrypt_password
    return if password.blank?
    self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
    self.crypted_password = encrypt(password)
  end
  
  def password_required?
    !password.blank?
  end
  
  def current_password_matches
    if require_current_password
      if (email_changed? || !password.blank? || login_changed?) &&
        (!crypted_password.blank? && !authenticated?(current_password))
        errors.add(:current_password, ' is not correct')
      end
    end
  end
  
  def generate_password_reset_code
    self.password_reset_code = random_digest
  end
  
  def random_digest
    ActiveSupport::SecureRandom.hex(20)
  end
end
