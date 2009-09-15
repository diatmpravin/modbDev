require 'bunny'

# Use SystemTimer if it is supported.
begin
  require 'system_timer'
  JasperTimer = SystemTimer
rescue LoadError
  require 'timeout'
  JasperTimer = Timeout
end

module JasperSmsGateway
  include LoadsYamlConfig
  loads_yaml_config :config, 'amqp.yml'

  def send(to, message, response_pattern = nil)
    from = '2001'
    response = nil
    
    Bunny.run(config) do |amqp|
      # Prepare exchanges and create an anonymous reply queue
      amqp.exchange('jasper')
      amqp.exchange('reply')
      
      reply = amqp.queue
      reply.bind('reply', :key => reply.name)
      
      # Send our message
      format = "#{from}/#{to}/1/#{response_pattern}/#{message}"
      amqp.exchange('jasper').publish(format, :reply_to => reply.name)
      
      # Wait for a response, if appropriate
      begin
        JasperTimer.timeout(45) do
          reply.subscribe do |msg|
            response = msg
            reply.unsubscribe
          end
        end
      rescue Timeout::Error
        # nil
      end
    end
  
    response
  end
  module_function :send
  
end