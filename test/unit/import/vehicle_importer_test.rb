require 'test_helper'

describe "Import::VehicleImporter", ActiveSupport::TestCase do

  specify "can store data in redis" do
    quentin = accounts(:quentin)
    quentin_user = users(:quentin)

    importer = Import::VehicleImporter.new(quentin, quentin_user)
    importer.store("filename.txt", %w(data is kind of cool))

    r = Redis.build
    found = r.get("mobd:import:#{quentin.id}:#{quentin_user.id}:filename.txt")

    ActiveSupport::JSON.decode(found).should.equal %w(data is kind of cool)
  end

end
