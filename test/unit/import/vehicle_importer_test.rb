require 'test_helper'

describe "Import::VehicleImporter", ActiveSupport::TestCase do

  setup do
    @quentin = accounts(:quentin)
    @quentin_user = users(:quentin)

    @importer = Import::VehicleImporter.new(@quentin, @quentin_user)
  end

  specify "can store data in redis" do
    key = "mobd:import:#{@quentin.id}:#{@quentin_user.id}:filename.txt"
    redis_mock = mock()
    redis_mock.expects(:set).with(key, %w(data is kind of cool).to_json, 3600)

    Redis::Client.expects(:build).returns(redis_mock)

    @importer.store("filename.txt", %w(data is kind of cool))
    @importer.data.should.equal %w(data is kind of cool)
  end

  specify "can take the data in redis and actually build vehicles accordingly" do
    data = [
      %w(Vehicle1 000000000000001 10203),
      %w(Vehicle2 000000000000002 20203),
      %w(Vehicle3 000000000000003 30203),
      %w(Vehicle4 000000000000004 40203),
      %w(Vehicle5 000000000000005 50203),
    ]

    key = "mobd:import:#{@quentin.id}:#{@quentin_user.id}:vehicles.csv"
    redis_mock = mock()
    redis_mock.expects(:get).with(key).returns(data.to_json)

    Redis::Client.expects(:build).returns(redis_mock)

    @quentin.devices.should.differ(:count).by(5) do
      @importer.process("vehicles.csv")
    end

    v1 = @quentin.devices.find_by_name("Vehicle1")
    v1.should.not.be.nil
    v1.vin_number.should.equal "000000000000001"

    @quentin.devices.find_by_name("Vehicle2").should.not.be.nil
    @quentin.devices.find_by_name("Vehicle3").should.not.be.nil
    @quentin.devices.find_by_name("Vehicle4").should.not.be.nil
    @quentin.devices.find_by_name("Vehicle5").should.not.be.nil

    @importer.results.should.equal [:success, :success, :success, :success, :success]
  end

  specify "can handle data that throws exceptions on import" do
    data = [
      %w(Vehicle1 1Z49382CB3344 10393),
      %w(Vehicle2 20203 1JJ3203948344),
      %w(Vehicle3 1BA9948232431 10000),
      %w(Vehicle4 40203 1PP3928493AA4),
      %w(Vehicle5 1Z23984AB3344 82922),
    ]

    key = "mobd:import:#{@quentin.id}:#{@quentin_user.id}:vehicles.csv"
    redis_mock = mock()
    redis_mock.expects(:get).with(key).returns(data.to_json)

    Redis::Client.expects(:build).returns(redis_mock)

    @quentin.devices.should.differ(:count).by(3) do
      @importer.process("vehicles.csv")
    end

    @quentin.devices.find_by_name("Vehicle1").should.not.be.nil
    @quentin.devices.find_by_name("Vehicle3").should.not.be.nil
    @quentin.devices.find_by_name("Vehicle5").should.not.be.nil

    @quentin.devices.find_by_name("Vehicle2").should.be.nil
    @quentin.devices.find_by_name("Vehicle4").should.be.nil

    @importer.results.should.equal [:success, :error, :success, :error, :success]
    @importer.errors[1].should.equal "Odometer is not a number"
    @importer.errors[3].should.match "Odometer is not a number"
  end

  specify "ignores vehicles that already exist in the system" do
    data = [
      ["Quentin's Device", "1Z49382CB3344", "10393"],
      %w(Vehicle2 1JJ3203948344 2023)
    ]

    key = "mobd:import:#{@quentin.id}:#{@quentin_user.id}:vehicles.csv"
    redis_mock = mock()
    redis_mock.expects(:get).with(key).returns(data.to_json)

    Redis::Client.expects(:build).returns(redis_mock)

    @quentin.devices.should.differ(:count).by(1) do
      @importer.process("vehicles.csv")
    end

    @importer.results.should.equal [:found, :success]
    @importer.errors.should.equal ["Vehicle already exists with this name"]
  end

end
