module PhonesDatabase
  class Phone < Connection

    # Get all phones for a given manufacturer_id
    def self.find_all_by_manufacturer_id(id)
      Phone.find(:all, :params => {:manufacturer_id => id})
    end

    # Get the manufacturer for this phone
    def manufacturer
      Manufacturer.find(self.manufacturer_id)
    end
  end
end
