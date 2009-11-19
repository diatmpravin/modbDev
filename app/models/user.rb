require 'digest/sha1'
class User < ActiveRecord::Base
  acts_as_tree :order => 'login', :dependent => nil
  
  belongs_to :account
  has_many :devices, :include => :tracker
  
  # Virtual attribute for the unencrypted password
  attr_accessor :password
  
  # Virtual attribute for current password
  attr_accessor :current_password
  
  validates_presence_of     :account
  validates_presence_of     :login, :email
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 4..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_length_of       :login,    :within => 3..30
  validates_length_of       :email,    :within => 3..50
  validates_uniqueness_of   :login, :case_sensitive => false, :scope => :account_id
  validate_on_update :current_password_matches
  validates_inclusion_of :time_zone, :in => ActiveSupport::TimeZone.us_zones.map {|z| z.name}
  
  # List accessible attributes here
  attr_accessible :login, :email, :password, :password_confirmation,
    :account, :current_password, :roles, :name, :time_zone, :devices
  
  before_save :encrypt_password
  before_create :make_activation_code
  before_destroy :promote_child_records

  # Work around bug:
  # https://rails.lighthouseapp.com/projects/8994-ruby-on-rails/tickets/2896-collection_singular_ids-breaks-when-used-with-include
  def device_ids
    Device.find_by_sql(["select d.id from devices d where user_id = ?", self.id]).map(&:id)
  end
  
  class Role
    # Defined as bit positions
    SUPERUSER = 1
    USERS = 2
    FLEET = 3
    DISPATCH = 4
    REPORTS = 5
    
    LIST = [SUPERUSER, USERS, FLEET, DISPATCH, REPORTS]
    
    OPTIONS = {
      SUPERUSER => 'Account Administrator',
      USERS => 'User Management',
      FLEET => 'Fleet Management',
      DISPATCH => 'Dispatch',
      REPORTS => 'Reports'
    }
  end
  
  # Return the user's roles in an array.
  # Return ALL roles if the user is a superuser.
  def roles
    return [] unless self[:roles]
    
    if (self[:roles] >> (Role::SUPERUSER-1)) & 0x01 == 0x01
      Role::LIST
    else
      Role::LIST.select { |r|
        (self[:roles] >> (r-1)) & 0x01 == 0x01
      }
    end
  end
  
  def roles=(array)
    array = array.map {|r| r.to_i}
    self[:roles] = (Role::LIST & array).inject(0) { |mask, r|
      mask |= (1 << (r-1))
    }
  end
  
  def has_role?(role)
    roles.include?(role)
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
  
  def send_activation_email
    Mailer.deliver_activation(self)
  end
  
  def forgot_password
    generate_password_reset_code
    save(false)
    
    Mailer.deliver_forgotten_password(self)
  end
  
  # Mark that this account is now active
  def activate
    self.activated_at = Time.now
    self.activation_code = nil
    self.save
  end

  def activated?
    !!self.activated_at
  end
  
  protected
  def encrypt_password
    return if password.blank?
    self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
    self.crypted_password = encrypt(password)
  end
  
  def password_required?
    crypted_password.blank? || !password.blank?
  end
  
  def current_password_matches
    if (email_changed? || !password.blank? || login_changed?) &&
      (!crypted_password.blank? && !authenticated?(current_password))
      errors.add(:current_password, ' is not correct')
    end
  end
  
  def random_digest
    ActiveSupport::SecureRandom.hex(20)
  end

  def generate_password_reset_code
    self.password_reset_code = random_digest
  end
  
  def make_activation_code
    self.activation_code = random_digest
  end
  
  def promote_child_records
    # Take any users or devices that were children of this user, and "promote"
    # them up the tree.
    User.update_all({:parent_id => self.parent_id}, {:parent_id => self.id})
    Device.update_all({:user_id => self.parent_id}, {:user_id => self.id})
    self.reload
  end
end
