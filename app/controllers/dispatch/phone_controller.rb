module Dispatch
  class PhoneController < Controller
    filter :require_activated_phone, :except => [:create, :activate, :activate_by_login]
    filter :require_valid_hash, :except => [:create, :activate, :activate_by_login]
    filter :set_device, :only => [:get_trip_map, :associate_geofence]
    filter :require_subscription, :except => [:create, :activate_by_login]
    
    def create
      phone = Phone.create
      {:phone => phone.activation_code}
    end
    
    def activate
      return error(Errors::INVALID_PHONE) if !phone
      return error(Errors::INACTIVE_PHONE) if !phone.moshi_key
      {:moshi_key => phone.moshi_key}
    end

    def activate_by_login
      return error(Errors::INVALID_PHONE) if !phone

      account = Account.authenticate(request[:username], request[:password])
      return error(Errors::INVALID_LOGIN) if !account

      unless phone.activate(account)
        return error(Errors::TOO_MANY_PHONES)
      end
      
      {:moshi_key => phone.moshi_key}
    end

    def session
      {
        :devices => phone.devices.map {|device| {
          :id => device.id,
          :name => device.name,
          :color => device.color,
          :geofence_ids => device.geofence_ids
        }},
        :geofences => phone.account.geofences.map {|geofence| {
          :id => geofence.id,
          :name => geofence.name,
          :alert_on_exit => geofence.alert_on_exit,
          :alert_on_entry => geofence.alert_on_entry
        }}
      }
    end
    
    def get_trips
      devices = if request[:device_id]
                  [phone.devices.find(request[:device_id])]
                elsif request[:device_ids]
                  phone.devices.find(request[:device_ids])
                else
                  phone.devices
                end
      start_date = Date.parse(request[:start_date])
      end_date = Date.parse(request[:end_date])
      
      trips = []
      trips = devices.map { |device|
        device.points.in_range(start_date, end_date, device.zone).in_trip.trips
      }.flatten.uniq
      
      response = {:trips => []}
      
      trips.each do |trip|
        hash = {
          :id => trip.id,
          :start_time => trip.start.to_i + trip.start.in_time_zone(trip.device.zone).utc_offset,
          :finish_time => trip.finish.to_i + trip.finish.in_time_zone(trip.device.zone).utc_offset,
          :miles => trip.miles,
          :device_id => trip.device_id,
          :events => trip.events.length
        }
        response[:trips] << hash
      end
      
      response
    end
    
    def get_map
      devices = if request[:device_id]
                  [phone.devices.find(request[:device_id])]
                elsif request[:device_ids]
                  phone.devices.find(request[:device_ids])
                else
                  phone.devices
                end
      
      positions = devices.map {|device| device.position}
      positions.reject!(&:nil? )
      
      if positions.empty?
        return error(Errors::NO_MAP_DATA)
      end
      
      if request[:session_id]
        session = MapQuest::Session.new(request[:session_id], request[:map_state])
        original_center = session.coordinates_for(MapQuest::Tile::OUTER_SIZE / 2 + request[:x],
          MapQuest::Tile::OUTER_SIZE / 2 + request[:y])
        session.zoom_to_level(request[:zoom_level])
        
        center = session.pixels_for(Point.new(
          :latitude => original_center[:latitude],
          :longitude => original_center[:longitude]
        )).first
      else
        session = MapQuest::Session.new
      
        session.best_fit(positions,
          request[:dimensions][:width],
          request[:dimensions][:height])
        
        center = [0, 0]
      end
      
      points = session.pixels_for(positions)
      points.each_index do |i|
        points[i] = {:x => points[i][0], :y => points[i][1]}
        points[i][:timestamp] = positions[i].occurred_at.to_i + positions[i].occurred_at.in_time_zone(positions[i].device.zone).utc_offset
        points[i][:speed] = positions[i].speed
        points[i][:rpm] = positions[i].rpm
        points[i][:device_id] = positions[i].device_id
      end
      
      {
        :session_id => session.session_id,
        :zoom_level => session.zoom_level,
        :center => {
          :x => center[0],
          :y => center[1]
        },
        :points => points,
        :tile_size => MapQuest::Tile::SIZE,
        :map_state => session.map_state
      }
    end
    
    def get_trip_map
      trip = @device.trips.find(request[:trip_id])
      
      if request[:session_id]
        session = MapQuest::Session.new(request[:session_id], request[:map_state])
        original_center = session.coordinates_for(MapQuest::Tile::OUTER_SIZE / 2 + request[:x],
          MapQuest::Tile::OUTER_SIZE / 2 + request[:y])
        session.zoom_to_level(request[:zoom_level])
        
        center = session.pixels_for(Point.new(
          :latitude => original_center[:latitude],
          :longitude => original_center[:longitude]
        )).first
      else
        session = MapQuest::Session.new
        
        session.best_fit(trip.points,
          request[:dimensions][:width],
          request[:dimensions][:height])
        
        center = [0, 0]
      end
      
      points = session.pixels_for(trip.points)
      points.each_index do |i|
        points[i] = {:x => points[i][0], :y => points[i][1]}
        points[i][:timestamp] = trip.points[i].occurred_at.to_i + trip.points[i].occurred_at.in_time_zone(@device.zone).utc_offset
        points[i][:speed] = trip.points[i].speed
        points[i][:rpm] = trip.points[i].rpm
        points[i][:heading] = trip.points[i].heading
        points[i][:altitude] = trip.points[i].altitude
        points[i][:events] = trip.points[i].events.map {|e| e.attributes.merge(:type_text => e.type_text)}
        points[i][:mpg] = -1 # temporary until we collect miles per gallon
      end
      
      {
        :session_id => session.session_id,
        :device_id => trip.device_id,
        :zoom_level => session.zoom_level,
        :center => {
          :x => center[0],
          :y => center[1]
        },
        :points => points,
        :tile_size => MapQuest::Tile::SIZE,
        :map_state => session.map_state
      }
    end
    
    def get_tile
      col = request[:col]
      row = request[:row]
      
      session = MapQuest::Session.new(request[:session_id])
      image = session.tile(col, row, request[:map_state])
      
      {
        :tiles => [{:col => col, :row => row, :length => image.length, :image => image}]
      }
    end
    
    def get_tiles
      session = MapQuest::Session.new(request[:session_id])
      
      tiles = []
      request[:tiles].each do |tile|
        image = session.tile(tile[:col], tile[:row], request[:map_state])
        
        tiles << {
          :col => tile[:col],
          :row => tile[:row],
          :length => image.length,
          :image => image
        }
      end
      
      {:tiles => tiles}
    end
    
    def associate_geofence
      @geofence = phone.account.geofences.find(request[:geofence_id])
      
      if request[:associated]
        @device.geofence_ids = (@device.geofence_ids << @geofence.id).uniq
        @device.save
      else
        @device.geofence_ids = (@device.geofence_ids - [@geofence.id]).uniq
        @device.save
      end
      
      {:geofence_ids => @device.geofence_ids}
    end
    
    protected
    def set_device
      @device = phone.devices.find(request[:device_id])
      true
    end
  end # PhoneController
end
