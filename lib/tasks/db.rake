namespace :db do

  desc <<-END
    Populate test point and trip data. 
    Use DEVICE_ID to hook this data up to an existing device.
    Use STAGE to specify which database to put this data in (default: development).
  END
  task :populate => :environment do
    device_id = ENV["DEVICE_ID"] 

    sql = File.read(Rails.root.join("db", "populate", "test_data.sql"))

    parts = sql.split(";")[0..-1]

    parts.each do |p|
      ActiveRecord::Base.connection.execute p unless p.strip.chomp.empty?
    end

    if device_id
      Point.reset_column_information
      Trip.reset_column_information

      [Point, Trip].each do |k|
        k.all.each {|x| x.device_id = device_id; x.save }
      end
    end
  end

end
