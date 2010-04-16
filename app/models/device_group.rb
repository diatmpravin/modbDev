class DeviceGroup < ActiveRecord::Base
  belongs_to :account
  has_many :devices, :foreign_key => :group_id, :order => 'name ASC', :dependent => :nullify
  has_many :users, :foreign_key => :device_group_id, :order => 'name ASC', :dependent => :nullify
  
  attr_accessible :account, :name, :grading, :parent_id
  
  acts_as_nested_set :scope => :account
  
  validates_presence_of :account
  validate :belongs_to_parent_account
  validates_presence_of :name
  validates_length_of :name, :maximum => 30,
    :allow_nil => true, :allow_blank => true
  
  serialize :grading

  default_value_for :grading do
    {}
  end
  
  # This class represents a "root" group, which isn't actually in the database
  class Root
    attr_accessor :id, :name, :children, :devices, :users
    
    def initialize(options = {})
      self.id = options[:id] || 0
      self.name = options[:name] || 'All'
      self.children = options[:children] || []
      self.devices = options[:devices] || []
      self.users = options[:users] || []
    end
  end
  
  ##
  # Concerns
  ##
  concerned_with :sphinx
  concerned_with :grading
  
  has_many :device_group_links
  
  # Here are all the "other" objects that can link to device groups
  has_many :geofences, :through => :device_group_links,
    :source => :link, :source_type => 'Geofence'
  has_many :landmarks, :through => :device_group_links,
    :source => :link, :source_type => 'Landmark'
  
  # Destroy this record AND rollup any devices or subgroups to the parent.
  # If this group is a root group, this is the same as a call to destroy.
  def destroy_and_rollup
    if parent
      self.children.each do |c|
        c.move_to_child_of(self.parent)
      end
      
      self.parent.devices   += self.devices
      self.parent.geofences += self.geofences
      self.parent.landmarks += self.landmarks
      self.parent.users += self.users
      self.parent.save
    else
      self.children.each do |c|
        c.move_to_root
      end
    end
    
    destroy
  end
  
  def self_and_descendants_devices
    account.devices.all(:joins => :group, :conditions => {:device_groups => {:lft => self.lft..self.rgt }})
  end

  protected
  
  def belongs_to_parent_account
    errors.add :parent_id, 'account mismatch' if parent && account_id != parent.account_id
  end

end
