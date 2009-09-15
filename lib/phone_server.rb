require 'eventmachine'

# Accepts TCP and HTTP socket connections from phones and handles
# phone requests.
#
# Requests from the phone are in JSON format. Each request is on
# a single line.
#
module PhoneServer
  include WithActiveRecord
  include LoadsYamlConfig
  loads_yaml_config :servers, 'phone_server.yml'
  
  def post_init
    @buffer = ""
  end
  
  def receive_data(data)
    @buffer << data
    
    if request = @buffer.slice!(/^\{.*?\}(\n|\r\n)/)
      EventMachine.defer(
        proc { handle_request request },
        proc { |response| send_data response }
      )
    end
  end
  
  # Main request handler
  def handle_request(request)
    with_active_record do
      log request
      
      response = Dispatch::Controller.dispatch(request)
      
      # (possibly) temporary - log response json and size of blob data
      l = response.split("\n", 2)
      log " -> #{l[0]} [#{l[1].length}]"
      
      response
    end
  end
  
  def log(message)
    @@logger ||= Logger.new(File.join(RAILS_ROOT, 'log', 'phone_server.log'))
    @@logger.info "#{Time.now.strftime("%Y-%m-%d %H:%M:%S")} #{message}"
  end
  module_function :log
  
  ##
  # Start the Phone Server
  #
  def run
    log "Phone Server started"
    
    EventMachine::run do
      servers.each_value do |server|
        EventMachine::start_server server[:host], server[:port], PhoneServer
      end
    end
  ensure
    log "Phone Server stopped"
  end
  module_function :run
end