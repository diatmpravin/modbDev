module ReportsHelper
  def report_partial(report)
    case report.report_type
      when 0
        'vehicle_summary'
      when 1
        'daily_summary'
      else
        nil
    end
  end
end
