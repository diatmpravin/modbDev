module Import

  # Import vehicle data from an uploaded file
  # 
  class VehicleImporter

    attr_reader :file_name, :data, :results, :errors

    def initialize(account, user)
      @account = account
      @user = user
    end

    # Given data and a file name, store the data
    # in JSON format into Redis
    def store(filename, data)
      @file_name = filename
      @data = data

      redis = Redis.build

      # Save data and set to expire this data after an hour
      redis.set(key(@file_name), data.to_json, (60 * 60))
    end

    # Assuming data exists in redis for the given filename
    # take that data and build vehicles
    def process(filename)
      redis = Redis.build
      @data = ActiveSupport::JSON.decode(redis.get(key(filename)))
      @results = []
      @errors = []

      Device.suspended_delta do
        @data.each_with_index do |entry, i|
          begin
            if @account.devices.find_by_name(entry[0])
              @results[i] = :found
              @errors[i] = "Already exists"
            else
              @account.devices.create! :name => entry[0], :vin_number => entry[1], :odometer => entry[2]
              @results[i] = :success
            end
          rescue ActiveRecord::RecordInvalid => ex
            @errors[i] = ex.message.split(": ")[1]
            @results[i] = :error
          end
        end
      end
    end

    protected

    def key(filename)
      "mobd:import:#{@account.id}:#{@user.id}:#{filename}"
    end

  end

end
