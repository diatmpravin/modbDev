# Local representation of a remote MapQuest session.
#
# Create a new remote MapQuest session:
#   MapQuest::Session.new
#
# Resume (continue using) an existing remote session:
#   MapQuest::Session.new(session_id)
#
# Some methods (like #best_fit) are used to update the remote session, others
# (like #map or #pixels_for) are used to retrieve images or data from the
# remote session.
module MapQuest
  class Session
    include MapQuest::RequestBuilder
    
    attr_accessor :request, :response, :map_state, :session_id, :options
    
    ZOOM_SCALE = [
      48000000,
      24000000,
      12000000,
      6000000,
      3000000,
      1600000,
      800000,
      400000,
      192000,
      96000,
      48000,
      24000,
      12000,
      6000
    ]
    
    class MapQuestError < StandardError
    end
    
    def zoom_level
      ZOOM_SCALE.index(map_state['Scale'].to_i)
    end
    
    # Create a new remote MapQuest session or resume using an existing one.
    def initialize(session_id = nil, map_state = nil)
      if session_id.blank?
        create_session
      else
        @session_id = session_id
      end
      
      if map_state
        @map_state = map_state
      end
    end

    # Move the center of the map to a given latitude/longitude.
    def center(lat, lng)
      update_session do |xml|
        xml.CenterLL {
          xml.CenterLatLng {
            xml.Lat lat
            xml.Lng lng
          }
        }
      end
    end
    
    # Move the map a certain number of pixels x/y. Optionally pass in an
    # original map state to pan from.
    def pan(x_delta, y_delta, map_state = nil)
      update_session(map_state ? 2 : 1) do |xml|
        if map_state
          @map_state = map_state
          set_map_state xml
        end
        xml.Pan {
          xml.DeltaPoint {
            xml.X x_delta
            xml.Y y_delta
          }
        }
      end
    end
    
    # Zoom to the specified level
    def zoom_to_level(new_level)
      zoom_to_scale ZOOM_SCALE[new_level]
    end
    
    # Zoom to the specified scale
    def zoom_to_scale(new_scale)
      @map_state.merge!('Scale' => new_scale)
      update_session do |xml|
        set_map_state xml
      end
      
      TileCache.clear(@session_id)
    end
    
    # Re-scale and recenter the map to fit the given list of Points. The next
    # call to #map will reflect the new map state.
    def best_fit(points, view_width, view_height)
      points = [points] unless points.is_a?(Array)
      
      # Override the default width/height so that all of the the points
      # fit onto the phone's screen.
      @map_state.merge!(
        'Width' => "%.6f" % (view_width / 72.0),
        'Height' => "%.6f" % (view_height / 72.0)
      )
      
      update_session(2) do |xml|
        set_map_state xml
        xml.BestFitLL('Version' => 2) {
          xml.LatLngs('Version' => 1, 'Count' => points.length) {
            LatLngCollection.new(points).build xml
          }
          xml.KeepCenter 0
          xml.SnapToZoomLevel 1
        }
      end
      
      # Now we need to switch back to the default width / height
      @map_state.merge!(
        'Width' => "%.6f" % (Tile::OUTER_SIZE / 72.0),
        'Height' => "%.6f" % (Tile::OUTER_SIZE / 72.0)
      )
      update_session do |xml|
        set_map_state xml
      end
    end
    
    # Convert a list of Points (lat/lng coords) into a list of pixel coords.
    # Returns an array in the form [[x, y], [x, y], ...].
    #
    # Note that any returned pixel coordinates will be transformed relative
    # to the offset of the center tile (see MapQuest::Tile).
    def pixels_for(points)
      points = [points] unless points.is_a?(Array)
      
      build_request do |xml|
        xml.LLToPix {
          xml.LatLngCollection {
            LatLngCollection.new(points).build xml
          }
          set_map_state xml
          set_display_state xml
          authenticate xml
        }
      end
      
      remote_call(:map)
      
      coll = @response['LLToPixResponse']['PointCollection']
      
      pixels = []
      if coll['X'].is_a?(Array)
        coll['X'].each_index do |i|
          pixels << [coll['X'][i], coll['Y'][i]]
        end
      else
        pixels << [coll['X'], coll['Y']]
      end
      
      pixels.each do |pixel|
        pixel[0] = pixel[0].to_i - Tile::OUTER_SIZE/2 - MapQuest::Tile::ORIGINAL_X_OFFSET
        pixel[1] = pixel[1].to_i - Tile::OUTER_SIZE/2 - MapQuest::Tile::ORIGINAL_Y_OFFSET
      end
      
      pixels
    end
    
    # Convert a given point in x/y into lat/lng coordinates, based on the
    # current map state.
    def coordinates_for(x, y)
      build_request do |xml|
        xml.PixToLL {
          xml.PointCollection {
            xml.X x
            xml.Y y
          }
          set_map_state xml
          set_display_state xml
          authenticate xml
        }
      end
      
      remote_call(:map)
      
      coll = @response['PixToLLResponse']['LatLngCollection']
      
      {:latitude => coll['Lat'].to_i / 1000000.0, :longitude => coll['Lng'].to_i / 1000000.0}
    end
    
    # Return the first tile of a map. Assumes that the current map state
    # represents outer tile 0,0.
    def initial_tile
      image = map
      
      TileCache.put(@session_id, 0, 0, image)
      TileCache.get(@session_id, 0, 0)
    end
    
    # Returns a specific tile of the map relative to the original tile. Will
    # return a cached tile whenever possible.
    def tile(col, row, original_map_state)
      image = TileCache.get(@session_id, col, row)
      
      if !image
        x, y = Tile.to_xy(col, row)
        pan(x, y, original_map_state)
        
        image = map
        
        TileCache.put(@session_id, col, row, image)
        image = TileCache.get(@session_id, col, row)
      end
      
      image
    end
    
    # Get and return the map image representing the current map state.
    def map
      build_request do |xml|
        xml.GetMapFromSession('Version' => 1) {
          xml.SessionID @session_id
          set_display_state xml
          authenticate xml
        }
      end
      
      remote_call(:map, :image)
      
      @response
    end
    
    def geocode
    end
    
    protected
    def create_session
      build_request do |xml|
        xml.CreateSession {
          xml.Session('Count' => 1) {
            xml.MapState {
              xml.Width "%.6f" % (Tile::OUTER_SIZE / 72.0)
              xml.Height "%.6f" % (Tile::OUTER_SIZE / 72.0)
            }
            xml.CoverageStyle('Count' => 4, 'Name' => 'classic') {
              # MapQuest logo
              xml.DTStyleEx {
                xml.DT 1577
                xml.StyleString 'visible false'
              }
              # MapQuest copyright
              xml.DTStyleEx {
                xml.DT 1537
                xml.StyleString 'visible false'
              }
              # Source copyright
              xml.DTStyleEx {
                xml.DT 1578
                xml.StyleString 'visible false'
              }
              # Scale
              xml.DTStyleEx {
                xml.DT 764
                xml.StyleString 'visible false'
              }
            }
          }
          authenticate xml
        }
      end
      
      remote_call(:map)
      
      @session_id = @response['CreateSessionResponse']['SessionID']
      @map_state = @response['CreateSessionResponse']['MapState']
      
      true
    end
    
    def update_session(objects_to_update = 1)
      build_request do |xml|
        xml.UpdateSession {
          xml.SessionID @session_id
          xml.Session('Count' => objects_to_update) {
            yield xml
          }
          authenticate xml
        }
      end
      
      remote_call(:map)
      
      @map_state = @response['UpdateSessionResponse']['MapState']
      
      true
    end
    
    def set_map_state(xml)
      xml << @map_state.to_xml(
        :root => 'MapState',
        :indent => 0,
        :skip_instruct => true,
        :skip_types => true
      )
    end
    
    def set_display_state(xml)
      xml.DisplayState('Version' => 1) {
        xml.ContentType Tile::FORMAT
        xml.DPI 72
        xml.AntiAlias 1
      }
    end
    
    def crop_to_center_tile(data)
      image = MiniMagick::Image.from_blob(data)
      image.extent("#{Tile::SIZE}x#{Tile::SIZE}" +
        "+#{Tile::OUTER_SIZE/2-Tile::ORIGINAL_X_OFFSET}" +
        "+#{Tile::OUTER_SIZE/2-Tile::ORIGINAL_Y_OFFSET}")
      image.to_blob
    end
  end
end