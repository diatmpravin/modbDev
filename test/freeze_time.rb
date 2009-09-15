class Time
  def self.metaclass
    class << self; self; end
  end

  def self.freeze(point_in_time = Time.now)
    new_time = case point_in_time
      when String then Time.parse(point_in_time)
      when Time then point_in_time
      else raise ArgumentError.new("argument should be a string or time instance")
    end

    class << self
      alias old_now now
    end

    metaclass.class_eval do
      define_method :now do
        new_time
      end
    end

    yield(new_time)

    class << self
      alias now old_now
      undef old_now
    end
  end
end
