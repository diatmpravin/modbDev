# Simple helper for using the ActiveRecord connection pool within EventMachine
module WithActiveRecord
  # Obtain a connection from the ActiveRecord connection pool, ensure it is
  # still valid, and execute the provided block.
  def with_active_record
    ActiveRecord::Base.connection_pool.with_connection do |conn|
      connect_delay = 0 
      begin 
        Account.last(:select => :id)
      rescue Exception 
        sleep connect_delay ; connect_delay += 1 
        ActiveRecord::Base.connection.reconnect! 
        retry unless connect_delay > 5
      end
      yield conn
    end
  end
end