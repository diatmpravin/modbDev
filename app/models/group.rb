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

  ##
  # Concerns
  ##
  concerned_with :sphinx

  # Every group linkage possible needs to have a declaration
  # here. This is as simple as adding to the list
  [
    :devices
  ].each do |link|

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


end
