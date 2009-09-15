# Collection of routing and geocoding functions.
module MapQuest
  module Routing
  
    # Returned "confidence" strings are in the format "XXYYY".  The first two
    # chars represent type of area returned, from L1 (specific location) to
    # A1 (country).  The next three refer to confidence level of the result at
    # the street, area, and zip code level (from A to C, or X for unused).
    #
    # If confidence becomes important in the app, code should be added to break
    # this string apart.
  
    class << self
      include MapQuest::RequestBuilder
      
      def geocode(address)
        build_request do |xml|
          xml.Geocode('Version' => 1) {
            xml.Address {
              xml.AdminArea1 'US'
              xml.AdminArea3 address[:state]
              xml.AdminArea5 address[:city]
              xml.PostalCode address[:zip]
              xml.Street address[:street]
            }
            
            xml.GeocodeOptionsCollection('Count' => 0)
            
            authenticate xml
          }
        end
        
        remote_call(:geocode)
        
        geo = @response['GeocodeResponse']['LocationCollection']['GeoAddress']
        
        {
          :latitude => geo['LatLng']['Lat'].to_f,
          :longitude => geo['LatLng']['Lng'].to_f,
          :confidence => geo['ResultCode']
        }
      end
      
    end
    
    #def route
    #  build_request do |xml|
    #    @request = xml.DoRoute('Version' => 2) {
    #      xml.LocationCollection('Count' => 2) {
    #        xml.GeoAddress {
    #          xml.LatLng {
    #            xml.Lat '42.81932'
    #            xml.Lng '-86.09248'
    #          }
    #        }
    #        xml.GeoAddress {
    #          xml.LatLng {
    #            xml.Lat '42.78886'
    #            xml.Lng '-86.10706'
    #          }
    #        }
    #      }
    #      xml.RouteOptions('Version' => 2) {
    #        xml.RouteType 1
    #        xml.NarrativeType -1
    #        xml.MaxShape 200
    #        xml.CovSwitcher ''
    #      }
    #      xml.SessionID '49a34551-0292-0005-02b7-2db8-001ec928a759'
    #      
    #      authenticate xml
    #    }
    #  end
    #  
    #  remote_call(:route)
    #  
    #  true
    #end
    
  end
end
