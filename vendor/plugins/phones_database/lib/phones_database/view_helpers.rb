module PhonesDatabase
  module ViewHelpers
    def phone_image_tag(image, options = {})
      image_tag "http://#{PhonesDatabase::Connection.site.host}/#{image}", options
    end
  end
end
