require 'set'

class Report
  attr_accessor :user, :type, :devices, :range, :errors, :data
  
  def initialize(user, opts = {})
    @user      = user
    @devices   = opts[:devices] || user.devices
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
    
    TODAY      = 0
    YESTERDAY  = 1
    THIS_WEEK  = 2
    LAST_WEEK  = 3
    THIS_MONTH = 4
    LAST_MONTH = 5
    THIS_YEAR  = 6
    CUSTOM     = 7
    
    def initialize(report, opts = {})
      @report = report
      @type = (opts[:type] || 0).to_i

      case @type
      when TODAY
        @start = @end = today
      when YESTERDAY
        @start = @end = today - 1.day
      when THIS_WEEK
        @start = today.beginning_of_week
        @end = today.end_of_week
      when LAST_WEEK
        @start = 1.week.ago(today).beginning_of_week
        @end = @start.end_of_week
      when THIS_MONTH
        @start = today.beginning_of_month
        @end = today.end_of_month
      when LAST_MONTH
        @start = 1.month.ago(today).beginning_of_month
        @end = @start.end_of_month
      when THIS_YEAR
        @start = today.beginning_of_year
        @end = today.end_of_year
      when CUSTOM
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

# Ensure the Report class is defined before referring to our subclasses.
[
  VehicleSummaryReport,
  DailySummaryReport,
  FuelEconomyReport,
  TripDetailReport,
  LandmarkSummaryReport,
  FuelSummaryReport
].tap do |reports|
  Report::REPORTS = reports.freeze
  
  reports.each_with_index do |report, i|
    Report.const_set report.name.underscore.upcase, i
  end
end
