require 'phones_database/connection'
require 'phones_database/carrier'
require 'phones_database/manufacturer'
require 'phones_database/phone'
require 'phones_database/view_helpers'

module PhonesDatabase

  # Takes a URL where the phones database resides.
  # Put this call in your appropriate [environment].rb
  def self.site=(url)
    Connection.site = url
    ActionView::Base.send(:include, PhonesDatabase::ViewHelpers)
  end

  # Configure this site to work for a given application id.
  # Application id is linked to applications on the phones database site.
  def self.app_id=(id)
    Finder.app_id = id
  end

end
