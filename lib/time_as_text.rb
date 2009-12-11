# Encapsulates the logic necessary to convert an English "HH:MM AM/PM"
# string into an integer representing seconds since midnight (and vice versa).
#
# Calling time_as_text creates a new (accessible) attribute by appending
# "_text" to the given symbol name, linking it to the original attribute with
# the appropriate seconds conversion.
# 
#   class Example
#     include TimeAsText
#     time_as_text :start_time
#   end
#
module TimeAsText
  def self.included(base) # :nodoc:
    base.extend ClassMethods
  end
  
  def self.seconds_to_text(sec)
    return '12:00 am' unless sec

    min = ( sec / 60) % 60
    hr = sec / 3600
    ampm = (hr >= 12 ? 'pm' : 'am')
    hr = hr % 12
    hr = 12 if hr == 0
    "%02d:%02d %s" % [hr, min, ampm]
  end
  
  def self.text_to_seconds(text)
    text =~ /(\d+):(\d+) ?(\S+)/
    ($1.to_i % 12) * 3600 + $2.to_i * 60 + ($3 == 'pm' ? 43200 : 0)
  end
  
  module ClassMethods
    def time_as_text(symbol)
      text_symbol = "#{symbol}_text"
      
      attr_accessor text_symbol
      attr_accessible text_symbol
      
      define_method(text_symbol.to_s) do
        instance_variable_get("@#{text_symbol}") || TimeAsText::seconds_to_text(send(symbol))
      end
      
      define_method("#{text_symbol}=") do |value|
        instance_variable_set("@#{text_symbol}", value)
        send("#{symbol}=", TimeAsText::text_to_seconds(value))
      end
    end
  end
  
end # TimeAsText
