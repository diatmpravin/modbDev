# The idea behind Group is that it can be a generic group of Anything
# in the system, from Devices to Users to Geofences, etc.
# Every group is to be given the class it is grouping, which goes
# in the 'of' field. Foreign key values of the actual Device/Geofence/whatever
# go in the many-to-many table column "group_links.link_id"
#
# A single Group only covers a single type, you cannot have a Group that
# combines Devices and Geofences, for example. Because of this, the
# many-to-many table can be as simple as possible, as all records with
# this Group's id will link to objects of the 'of' class.
#
# See Device for how to hook up the other side of this.
#
class Group < ActiveRecord::Base
  belongs_to :account

  # parent_id is not accessible because attempting to set parent_id= is almost
  # always invalid. use a method like move_to_child_of instead.
  attr_accessible :account, :name
  
  acts_as_nested_set :scope => :account
  
  validates_presence_of :account
  validate :belongs_to_parent_account

  serialize :grading

  default_value_for :grading do 
    {}
  end

  ##
  # Concerns
  ##
  concerned_with :sphinx
  concerned_with :grading

  # Every group linkage possible needs to have a declaration
  # here. This is as simple as adding to the list
  LINKS = [ :devices ].freeze unless defined?(LINKS)

  LINKS.each do |link|

    # Link up
    has_and_belongs_to_many link,
      :join_table => :group_links,
      :association_foreign_key => :link_id,
      :uniq => true

    # And scope out
    named_scope "of_#{link}",
      :conditions => {:of => link.to_s.classify},
      :order => "name ASC"
  end

  # Destroy this record AND rollup any devices or subgroups to the parent.
  # If this group is a root group, this is the same as a call to destroy.
  def destroy_and_rollup
    unless self.parent
      destroy ; return
    end
    
    self.children.each do |c|
      c.move_to_child_of(self.parent)
    end
    
    LINKS.each do |link_name|
      self.send(link_name).each do |link|
        parent.send(link_name) << link
      end
    end
    
    destroy
  end
  
  protected
  
  def belongs_to_parent_account
    errors.add :parent_id, 'account mismatch' if parent && account_id != parent.account_id
  end
end
