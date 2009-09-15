# Wrapper library for calls to the MapQuest remote server.
# 
# In general, you should instantiate a MapQuest::Session model instead of
# referring to this module directly.
module MapQuest
  module Server
    MAP = 'map.access.mapquest.com'
    GEOCODE = 'geocode.access.mapquest.com'
    ROUTE = 'route.access.mapquest.com'
  end
  
  # Make a remote call to MapQuest. Server type should be one of :map,
  # :geocode, or :route (or pass server URL directly).
  def self.call(server_type, request_xml)
    response = Net::HTTP.start(server_for(server_type)) do |http|
      http.post('/mq/mqserver.dll?e=5&', request_xml)
    end
    
    response.body
  end
  
  def self.server_for(symbol_or_url)
    case symbol_or_url
      when :map
        Server::MAP
      when :geocode
        Server::GEOCODE
      when :route
        Server::ROUTE
      else
        symbol_or_url
    end
  end
  
  module ContentType
    GIF = 0
    PNG = 3
    
    def ContentType::file_suffix(type)
      {
        GIF => 'gif',
        PNG => 'png'
      }[type]
    end
  end
  
  module Tile
    CACHE = File.join(Rails.root, 'tmp', 'cache')
    
    # Image format
    FORMAT = ContentType::PNG
    
    # Tile width and height in pixels
    SIZE = 64
    
    # Number of subtiles across and down each MapQuest tile
    OUTER_TILES = 4
    
    # "Outer" tile size (map slices)
    OUTER_SIZE = OUTER_TILES*SIZE
    
    # Outer tile "border" (area outside the tiled portion)
    BORDER = 0
    
    # The offset of the map's center inside the original tile
    ORIGINAL_X_OFFSET = 0
    ORIGINAL_Y_OFFSET = 0
    
    # The tile offset of the center tile in the map slice
    INNER_COL_OFFSET = 2
    INNER_ROW_OFFSET = 2
    
    # Return the x/y position of the OUTER tile (map slice) containing
    # the given col/row. Pixels returned as [x,y].
    def Tile.to_xy(col, row)
      col = (col + INNER_COL_OFFSET) / OUTER_TILES
      row = (row + INNER_ROW_OFFSET) / OUTER_TILES
      
      [col * OUTER_SIZE, row * OUTER_SIZE]
    end
  end
  
  module TileCache
    include MapQuest::Tile
    
    # Cache the given MapQuest image as a collection of subtiles (a total of
    # OUTER_TILES^2 tiles). The given col/row can be the position of any of
    # the subtiles within the image.
    def self.put(session_id, col, row, image)
      source_file = MojoMagick.tempfile(image)
      folder = folder_for(session_id)
      
      FileUtils.mkpath(folder)
      dest_pattern = File.join(folder, file_pattern(col, row))
      
      MojoMagick.raw_command(
        "convert",
        "#{source_file} -shave #{BORDER}x#{BORDER} -crop #{OUTER_SIZE}x#{OUTER_SIZE}+0+0 +repage -crop #{SIZE}x#{SIZE} +repage -strip #{dest_pattern}"
      )
    end
    
    # Return the cached image for the given session id and col/row, or nil
    # if the file does not exist.
    def self.get(session_id, col, row)
      fname = File.join(folder_for(session_id), file_name(col, row))
      
      return nil unless File.exist?(fname)
      
      begin
        f = File.new fname
        f.binmode
        f.read
      ensure
        f.close
      end
    end
    
    # Clear all cached tiles for the given session id.
    def self.clear(session_id)
      FileUtils.rm Dir.glob(File.join(folder_for(session_id), '*'))
    end
    
    def self.file_name(col, row)
      col += INNER_COL_OFFSET
      row += INNER_ROW_OFFSET
      tile_number = (col % OUTER_TILES) + (row % OUTER_TILES) * OUTER_TILES
      col /= OUTER_TILES
      row /= OUTER_TILES
      
      "tile#{col}_#{row}_#{tile_number}.#{ContentType::file_suffix(Tile::FORMAT)}".underscore
    end
    
    def self.file_pattern(col, row)
      col = (col + INNER_COL_OFFSET) / OUTER_TILES
      row = (row + INNER_ROW_OFFSET) / OUTER_TILES
      
      "tile#{col}_#{row}_%d.#{ContentType::file_suffix(Tile::FORMAT)}".underscore
    end
    
    def self.folder_for(session_id)
      File.join(Tile::CACHE, session_id.underscore)
    end
  end
  
  require File.expand_path(File.join(File.dirname(__FILE__), 'map_quest', 'lat_lng_collection'))
  require File.expand_path(File.join(File.dirname(__FILE__), 'map_quest', 'session'))
end