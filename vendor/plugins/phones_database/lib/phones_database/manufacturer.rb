module PhonesDatabase
  class Manufacturer < Connection

    # Get the phones for this manufacturer
    def phones
      Phone.find_all_by_manufacturer_id(self.id)
    end

  end
end
