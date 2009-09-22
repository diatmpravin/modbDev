module Dispatch
  class Controller
    attr_accessor :request, :response, :phone
    
    def initialize(request)
      @request = request
    end
    
    # Take a JSON request string, turn it into a request hash, and
    # forward it to the appropriate controller and action. The response will
    # be returned as a JSON string (or JSON string + blob, if appropriate).
    def self.dispatch(request_string)
      request = ActiveSupport::JSON.decode(request_string).with_indifferent_access
      
      controller_name = "#{request[:controller] || 'phone'}_controller".camelize
      
      begin
        controller_class = Dispatch.const_get(controller_name)
      rescue NameError
        raise UnknownController
      end
      
      unless controller_class.respond_to_action?(request[:action])
        raise UnknownAction
      end
      
      controller = controller_class.new(request)
      
      response = true
      controller_class.filters_for(request[:action]).each do |filter|
        response = controller.send(filter.to_s)
        break if response != true
      end
      
      if response == true
        response = controller.send(request[:action])
      end
      
      response[:code] ||= 0
      
      # Append any image blobs to the bottom of the response, if they exist
      binary_data = ''
      
      if response[:tiles]
        response[:tiles].each do |tile|
          binary_data << tile.delete(:image)
        end
      end
      
      ActiveSupport::JSON.encode(response) + "\n" + binary_data
    rescue UnknownController
      ActiveSupport::JSON.encode(error(Errors::INVALID_COMMAND)) + "\n"
    rescue UnknownAction
      ActiveSupport::JSON.encode(error(Errors::INVALID_COMMAND)) + "\n"
    rescue => e
      Rails.logger.error "#{e.to_s}\n#{e.backtrace.map{|x| '  '+x}.join("\n")}"
      ActiveSupport::JSON.encode({:code => Errors::FATAL_ERROR, :error => e.to_s}) + "\n"
    end
    
    protected
    def set_phone
      self.phone = Phone.find_by_activation_code(request[:phone])
      true
    end
    
    def require_activated_phone
      if phone && phone.activated?
        true
      else
        error(Errors::INVALID_PHONE)
      end
    end
    
    def require_valid_hash
      if phone.moshi_key == request[:moshi_key]
        true
      else
        error(Errors::INVALID_MOSHI_KEY)
      end
    end

    def require_subscription
      # TODO: FIX!
      #if (phone && phone.account && phone.account.subscription && phone.account.subscription.cancelled?)
      #  error(Errors::BAD_SUBSCRIPTION)
      #else
        true
      #end
    end
  
    class << self
      def respond_to_action?(symbol)
        (self.public_instance_methods -
          self.superclass.public_instance_methods).include?(symbol)
      end
      
      def filter(symbol, opts = {})
        @filters ||= []
        @filters << {
          :method => symbol,
          :except => [opts[:except]].flatten || [],
          :only => [opts[:only]].flatten || []
        }
      end
      
      def filters
        @filters ||= []
        if superclass.respond_to? :filters
          superclass.filters + @filters
        else
          @filters
        end
      end
        
      def filters_for(action)
        filters.reject {|hash|
          (hash[:only].any? && !hash[:only].include?(action.to_sym)) ||
          hash[:except].include?(action.to_sym)
        }.map {|hash| hash[:method]}
      end
      
      def error(error_type)
        {:code => error_type, :error => Errors::TEXT[error_type]}  
      end
    end
    
    def error(error_type)
      self.class.error(error_type)
    end
    
    filter :set_phone
  end
  
  class UnknownController < StandardError ; end
  class UnknownAction < StandardError ; end
  
  module Errors
    INVALID_PHONE = 1
    INVALID_COMMAND = 2
    INVALID_MOSHI_KEY = 3
    INACTIVE_PHONE = 4
    INVALID_LOGIN = 5
    NO_MAP_DATA = 6
    TOO_MANY_PHONES = 7
    BAD_SUBSCRIPTION = 8
    
    FATAL_ERROR = 999
    
    TEXT = {
      INVALID_PHONE => "Invalid phone activation code",
      INVALID_COMMAND => "Invalid command",
      INVALID_MOSHI_KEY => "Invalid request",
      INACTIVE_PHONE => "Inactive phone",
      INVALID_LOGIN => "Login failed",
      NO_MAP_DATA => "No map data",
      TOO_MANY_PHONES => "Phone limit reached",
      BAD_SUBSCRIPTION => "Subscription has expired"
    }
  end
end
