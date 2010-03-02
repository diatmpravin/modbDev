class Tracker < ActiveRecord::Base

  ##
  # Sphinx Index Definitions
  ##
  define_index do
    indexes :imei_number, :sortable => true
    indexes :account_id, :sortable => true
    indexes account(:name), :as => :account_name

    has :created_at, :updated_at
    
    set_property :delta => true
  end

end

