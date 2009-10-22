require 'set'

class Report
  autoload :DailySummaryReport, 'report/daily_summary_report'
  autoload :VehicleSummaryReport, 'report/vehicle_summary_report'

  attr_accessor :account, :type, :devices, :range

  def initialize(account, opts = {})
    @account   = account
    @type      = (opts[:type] || 0).to_i
    @devices   = opts[:devices] || account.devices
    @generator = generator_for(@type)
    @range     = DateRange.new(self, opts[:range] || {})
  end

  def title
    @generator.title
  end

  def valid?
    @generator.valid?
  end

  def errors
    @generator.errors
  end

  def data
    @generator.data
  end
  alias :run :data

  def generator_for(type)
    case(type)
    when 0
      VehicleSummaryReport.new(self)
    when 1
      DailySummaryReport.new(self)
    when 2
      FuelEconomyReport.new(self)
    end
  end
  
  class DateRange
    attr_reader :type, :start, :end

    def initialize(report, opts = {})
      @report = report
      @type = (opts[:type] || 0).to_i

      case @type
      when 0 # Today
        @start = @end = today
      when 1 # Yesterday
        @start = @end = today - 1.day
      when 2 # This Week
        @start = today.monday
        @end = today
      when 3 # Last Week
        @start = today.monday - 1.week
        @end = @start.end_of_week
      when 4 # This Month
        @start = today.beginning_of_month
        @end = today
      when 5 # Last Month
        @start = today.beginning_of_month - 1.month
        @end = @start.end_of_month
      when 6 # This Year
        @start = today.beginning_of_year
        @end = today
      when 7 # Custom
        @start = Date.parse(opts[:start] || '')
        @end = Date.parse(opts[:end] || '')
      end
    rescue ArgumentError
      @report.errors << 'You must specify valid start and end dates'
    end

    def today
      @report.account.today
    end
  end

  class Generator
    attr_reader :report

    def initialize(report)
      @report = report
    end

    def title
      ''
    end

    def valid?
      true
    end

    def errors
      @errors ||= Set.new
    end

    def data
      @data ||= run
    end

    def devices
      @report.devices
    end

    def start
      @report.range.start
    end

    def end
      @report.range.end
    end

    def account
      @report.account
    end
  end
end
