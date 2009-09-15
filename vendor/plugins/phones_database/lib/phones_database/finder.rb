module PhonesDatabase

  # Class that hooks into the /finder.xml query
  # subsystem
  class Finder < Connection
    self.element_name = "finder"

    @@app_id = nil
    cattr_accessor :app_id

    # Clean interface to the many options that can be sent into the 
    # Phones Database Finder system. 
    #
    #   options - Can be any or all of the following:
    #     :query - The search query
    #     :phone_id - A specific phone id
    #     :carrier - ID of carrier to limit search on
    #     :manufacturer - ID of manufacturer to limit search on
    #     :limit - Limit the search down to this many items
    #     :app - ID of the application to limit search on
    #
    # The application ID is given to the app. The rest
    # can be queried as needed.
    #
    def self.search(options = {})
      p = {}
      [:carrier, :manufacturer, :app].each do |key|
        p[key] = options[key] if options[key]
      end

      p[:app] = @@app_id if @@app_id

      p[:q] = options[:query] if options[:query]
      p[:id] = options[:phone_id] if options[:phone_id]
      
      self.find(:one, :from => "/finder.xml", :params => p)
    end
  end

end
