module ReportsHelper
  def report_partial(report)
    report.class.name.underscore
  end

  def duration_format(seconds)
    minutes = seconds.to_i / 60
    "%02d:%02d" % [minutes / 60, minutes % 60]
  end

  def mpg_format(mpg)
    "%.1f" % mpg
  end

  def average(report, col, rows)
    rows == 0 ? 0 : report.data.sum(col) / rows
  end
  
  def report_options
    @@report_options ||= Report.valid_reports.enum_with_index.map {|clazz, i|
      [clazz.name.titleize, i]
    }.freeze
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
  
end
