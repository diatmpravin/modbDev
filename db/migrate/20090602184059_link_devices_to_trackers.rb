class LinkDevicesToTrackers < ActiveRecord::Migration
  def self.up
    imei = {}
    Device.find(:all).each do |d|
      imei[d.id] = d.imei_number
    end
  
    remove_column :devices, :imei_number
    add_column :devices, :tracker_id, :integer
    
    Device.reset_column_information
    Device.find(:all).each do |d|
      tracker = Tracker.create(:imei_number => imei[d.id])
      d.tracker_id = tracker.id
      d.save
    end
    
  end

  def self.down
    add_column :devices, :imei_number, :string, :limit => 32
    remove_column :devices, :tracker_id
  end
end