# Utility methods for building MapQuest requests.
# Intended to be mixed in.
module MapQuest
  module RequestBuilder
  
    def build_request
      xml = Builder::XmlMarkup.new
      xml.instruct!
      
      @request = yield xml
    end
    
    def remote_call(call_type, response_type = :xml)
      res = MapQuest.call(call_type, @request)
      
      if res =~ /^Status Code/
        raise MapQuestError.new(res)
      end
      
      case response_type
        when :xml
          @response = Hash.from_xml(res)
        when :image
          @response = res
      end
    rescue REXML::ParseException
      raise MapQuestError.new("invalid xml")
    end
    
    def authenticate(xml)
      xml.Authentication {
        xml.ClientId '34242'
        xml.Password 'vUsc94Hy'
      }
    end
    
  end
end
