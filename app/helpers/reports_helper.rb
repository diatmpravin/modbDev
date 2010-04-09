module ReportsHelper
  def report_partial(report)
    report.class.name.underscore
  end

  def duration_format(seconds)
    minutes = seconds.to_i / 60
    "%02d:%02d" % [minutes / 60, minutes % 60]
  end

  def mpg_format(mpg)
    "%.1f" % (mpg || 0).to_f
  end

  def percentage_format(pct) 
    pct ? "%.2f\%" % pct : "-"
  end

  def average(report, col, rows)
    rows == 0 ? 0 : report.data.sum(col) / rows
  end
  
  def landmark_report_options
    @@landmark_report_options ||= [
      ['Landmark Summary Report', Report::LANDMARK_BY_LANDMARK_SUMMARY_REPORT],
    ].freeze
  end
  
  def vehicle_report_options
    @@vehicle_report_options ||= [
      ['Vehicle Summary Report', Report::VEHICLE_SUMMARY_REPORT],
      ['Daily Summary Report', Report::DAILY_SUMMARY_REPORT],
      ['Fuel Economy Report', Report::FUEL_ECONOMY_REPORT],
      ['Trip Detail Report', Report::TRIP_DETAIL_REPORT],
      ['Landmark Report', Report::LANDMARK_SUMMARY_REPORT],
      ['Exception Detail Report', Report::EXCEPTION_SUMMARY_REPORT],
      ['Operating Time Summary Report', Report::OPERATING_TIME_SUMMARY_REPORT],
      ['After Hours Detail Report', Report::AFTER_HOURS_DETAIL_REPORT],
      ['Fuel Summary Report', Report::FUEL_SUMMARY_REPORT],
      ['Landmark Summary Report', Report::LANDMARK_BY_LANDMARK_SUMMARY_REPORT]
    ].freeze
  end
  
  def group_report_options
    @@group_report_options ||= [
      ['Vehicle Summary Report', Report::VEHICLE_SUMMARY_REPORT],
      ['Trip Detail Report', Report::TRIP_DETAIL_REPORT],
      ['Fuel Summary Report', Report::FUEL_SUMMARY_REPORT]
    ].freeze
  end
  
  def range_options
    @@range_options ||= [
      ['Today',      Report::DateRange::TODAY],
      ['Yesterday',  Report::DateRange::YESTERDAY],
      ['This Week',  Report::DateRange::THIS_WEEK],
      ['Last Week',  Report::DateRange::LAST_WEEK],
      ['This Month', Report::DateRange::THIS_MONTH],
      ['Last Month', Report::DateRange::LAST_MONTH],
      ['This Year',  Report::DateRange::THIS_YEAR],
      ['Custom',     Report::DateRange::CUSTOM]
    ].freeze
  end

  def range_options_report_card
    @@range_options_report_card ||= [
      ['Yesterday',  Report::DateRange::YESTERDAY],
      ['This Week',  Report::DateRange::THIS_WEEK],
      ['Last Week',  Report::DateRange::LAST_WEEK],
      ['This Month', Report::DateRange::THIS_MONTH],
      ['Last Month', Report::DateRange::LAST_MONTH],
    ].freeze
  end
  
end
