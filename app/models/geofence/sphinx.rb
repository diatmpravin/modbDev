class Geofence < ActiveRecord::Base

  ##
  # Sphinx Index Definitions
  ##
  define_index do
    indexes :name, :sortable => true
    indexes device_groups.name, :as => :group_name

    has :account_id, :created_at, :updated_at

    set_property :delta => true
  end

end
