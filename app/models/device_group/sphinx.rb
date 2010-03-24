class DeviceGroup < ActiveRecord::Base

  ##
  # Sphinx Index Definitions
  ##
  define_index do
    indexes :name, :sortable => true

    has :account_id, :created_at, :updated_at

    set_property :delta => true
  end

end
