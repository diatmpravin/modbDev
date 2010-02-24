class Account < ActiveRecord::Base

  ##
  # Sphinx Index Definitions
  ##
  define_index do
    indexes :name, :sortable => true
    indexes :number, :sortable => true
    
    has :parent_id, :as=> :account_id
    has :created_at, :updated_at

    set_property :delta => true
  end

end

