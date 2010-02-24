require 'test_helper'

describe "Import::VehicleImporter", ActiveSupport::TestCase do

  setup do
    @quentin = accounts(:quentin)
    @quentin_user = users(:quentin)

    @importer = Import::VehicleImporter.new(@quentin, @quentin_user)
  end

  specify "can store data in redis" do
    @importer.store("filename.txt", %w(data is kind of cool))

    r = Redis.build
    found = r.get("mobd:import:#{@quentin.id}:#{@quentin_user.id}:filename.txt")

    ActiveSupport::JSON.decode(found).should.equal %w(data is kind of cool)

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
    @importer.store("vehicles.csv", data)

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
  end

end
