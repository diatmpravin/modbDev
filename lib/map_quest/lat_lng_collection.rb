# Local representation of MapQuest's lat/lng list format.  Coordinates
# are represented as fixed point longs with 6-digit precision, each
# point relative to the preceding one.
#
# Usage:
#   LatLngCollection.new(point_array).build(xml_builder)
module MapQuest
  class LatLngCollection
    def initialize(points)
      @points = points
    end
    
    def build(xml)
      old_lat = old_lng = 0
      
      @points.each do |point|
        new_lat = point.latitude * 1000000
        new_lng = point.longitude * 1000000
        
        xml.Lat "%d" % (new_lat - old_lat)
        xml.Lng "%d" % (new_lng - old_lng)
        
        old_lat = new_lat
        old_lng = new_lng
      end
    end
  end
end