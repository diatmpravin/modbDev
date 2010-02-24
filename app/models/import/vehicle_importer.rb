module Import

  # Import vehicle data from an uploaded file
  # 
  class VehicleImporter

    attr_reader :file_name, :data

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
      redis.set(key(@file_name), data.to_json)
    end

    # Assuming data exists in redis for the given filename
    # take that data and build vehicles
    def process(filename)
      redis = Redis.build
      data = ActiveSupport::JSON.decode(redis.get(key(filename)))

      Device.suspended_delta do
        data.each do |entry|
          @account.devices.create! :name => entry[0], :vin_number => entry[1], :odometer => entry[2]
        end
      end
    end

    protected

    def key(filename)
      "mobd:import:#{@account.id}:#{@user.id}:#{filename}"
    end

  end

end
