# Include this module into your class to enable logging
module Logging

  def self.included(base)
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)
  end

  module ClassMethods
    def log_to(name)
      self.logger = Logger.new(File.join(File.dirname(__FILE__), %W(.. log #{name}.log)))
    end

    def logger
      self.logger = Logger.new(STDOUT) if !@logger
      @logger
    end

    def logger=(logger)
      @logger = logger

      # Define a consistant format for all messages regardless of what was given
      @logger.formatter = Proc.new do |sev, time, _, msg|
        if(msg.is_a?(Exception))
          msg = "#{msg.message}\n#{msg.backtrace.join("\n")}"
        end

        "%s: %s - %s\n" % [sev.ljust(6), time.strftime("%Y-%m-%d %H:%M:%S"), msg]
      end

      @logger
    end
  end

  module InstanceMethods
    def logger
      self.class.logger
    end
  end
end
