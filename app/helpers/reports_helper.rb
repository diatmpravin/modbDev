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
    report.data.sum(col) / rows
  end

  def report_type_options
    @@report_type_options ||= 
      @reports.map do |key, value|
        [value.name.titleize, key]
      end.freeze
  end

  def report_range_options
    @@range_type_options ||= [
      ['Today',      0],
      ['Yesterday',  1],
      ['This Week',  2],
      ['Last Week',  3],
      ['This Month', 4],
      ['Last Month', 5],
      ['This Year',  6],
      ['Custom',     7]
    ].freeze
  end
end
