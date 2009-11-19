require 'set'

class Report
  attr_accessor :user, :type, :devices, :range, :errors, :data

  def initialize(user, opts = {})
    @user      = user
    @devices   = opts[:devices] || user.device_ids
    @type      = opts[:type].to_i || 0
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

  # Get today's date
  def today
    @range.today
  end

  # Get this report as CSV
  def to_csv
    self.data.to_csv
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
        @start = today.beginning_of_week
        @end = today.end_of_week
      when 3 # Last Week
        @start = 1.week.ago(today).beginning_of_week
        @end = @start.end_of_week
      when 4 # This Month
        @start = today.beginning_of_month
        @end = today.end_of_month
      when 5 # Last Month
        @start = 1.month.ago(today).beginning_of_month
        @end = @start.end_of_month
      when 6 # This Year
        @start = today.beginning_of_year
        @end = today.end_of_year
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
      @report.user.zone.today
    end
  end
end
