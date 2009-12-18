class User < ActiveRecord::Base

  ##
  # Sphinx Index Definitions
  ##
  define_index do
    indexes :login, :sortable => true, :as => :username
    indexes :name, :sortable => true
    indexes :email, :sortable => true
    
    has :account_id, :created_at, :updated_at

    set_property :delta => true
  end

end

