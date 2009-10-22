module ReportsHelper
  def report_partial(report)
    case report.type
      when 0
        'vehicle_summary'
      when 1
        'daily_summary'
      else
        nil
    end
  end

  def report_type_options
    @@report_type_options ||= [
      ['Vehicle Summary Report', 0],
      ['Daily Summary Report', 1]
    ].freeze
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
