module Import

  # Import vehicle data from an uploaded file
  # 
  class VehicleImporter

    attr_reader :file_name

    def initialize(account, user)
      @account = account
      @user = user
    end

    # Given data and a file name, store the data
    # in JSON format into Redis
    def store(filename, data)
      @file_name = filename
      redis = Redis.build
      redis.set(key(@file_name), data.to_json)
    end

    protected

    def key(filename)
      "mobd:import:#{@account.id}:#{@user.id}:#{filename}"
    end

  end

end
