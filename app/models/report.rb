require 'set'

class Report
  attr_accessor :account, :type, :devices, :range, :errors, :data

  def initialize(account, opts = {})
    @account   = account
    @devices   = opts[:devices] || account.devices
    @errors    = Set.new
    @range     = DateRange.new(self, opts[:range] || {})
  end

  # Get the title of the report
  def title
    raise "Reports must define a title"
  end

  # Implement this method in the individual reports
  # to handle parameter validation logic
  def validate
  end

  # Check if the parameters passed into this report are valid.
  # Basically, check that the errors set is empty
  def valid?
    @errors.empty?
  end

  # Get the start date of the given date range
  def start
    @range.start
  end

  # Get the end date of the given date range
  def end
    @range.end
  end

  # Run the report, this needs to populate @data
  def run
    raise "Report must define #run which should build the report"
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

        if @start > @end
          @report.errors << "Start date must be earlier or equal to end date"
        end
      end
    rescue ArgumentError
      @report.errors << 'You must specify valid start and end dates'
    end

    def today
      @report.account.today
    end
  end
end
