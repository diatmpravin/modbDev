class Landmark < ActiveRecord::Base

  # Sphinx indexing definitions
  define_index do
    indexes :name, :sortable => true

    # Thinking Sphinx expects these to be in radian values
    # We store as degree, so we need to convert
    has "RADIANS(latitude)",  :as => :latitude,  :type => :float
    has "RADIANS(longitude)", :as => :longitude, :type => :float

    has :account_id, :created_at, :updated_at

    set_property :delta => true
  end

end
