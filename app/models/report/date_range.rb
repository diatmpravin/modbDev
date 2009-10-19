class Report
  module DateRange
    class Base
      attr_reader :type

      def initialize(id)
        @type = id
      end

      def call(account)
        raise Unsupported
      end
    end

    class Today < Base
      def call(today, last = nil)
        [ today ]
      end

      def label
        'Today'
      end
    end

    class Yesterday < Base
      def call(today, last = nil)
        [ today - 1.day ]
      end

      def label
        'Yesterday'
      end
    end

    class ThisWeek < Base
      def call(today, last = nil)
        [ today.monday, today ]
      end

      def label
        'This Week'
      end
    end

    class LastWeek < Base
      def call(today, last = nil)
        start = today.monday - 1.week

        [ start, start.end_of_week ]
      end

      def label
        'Last Week'
      end
    end

    class ThisMonth < Base
      def call(today, last = nil)
        [ today.beginning_of_month, today ]
      end

      def label
        'This Month'
      end
    end

    class LastMonth < Base
      def call(today, last = nil)
        start = today.beginning_of_month - 1.month

        [ start, start.end_of_month ]
      end
      
      def label
        'Last Month'
      end
    end

    class ThisYear < Base
      def call(today, last = nil)
        [ today.beginning_of_year, today ]
      end

      def label
        'This Year'
      end
    end

    class Custom < Base
      def call(first, last)
        [ Date.parse(first), Date.parse(last) ]
      end

      def label
        'Custom'
      end
    end

    TYPES = [
      Today.new(0),
      Yesterday.new(1),
      ThisWeek.new(2),
      LastWeek.new(3),
      ThisMonth.new(4),
      LastMonth.new(5),
      ThisYear.new(6),
      Custom.new(7)
    ].freeze

    class << self
      def type_options
        @range_type_options ||= Report::DateRange::TYPES.map {|t| [ t.label, t.type ]}
      end

      def for_type(type)
        TYPE[type]
      end
    end
  end
end
