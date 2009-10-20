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

  def report_type_options
    @@report_type_options ||= [].tap do |opts|
      Report::TYPES.keys.sort.each do |k|
        opts << [ Report::TYPES[k], k ]
      end
    end
  end

  def report_range_options
    @@range_type_options ||= Report::DateRange::TYPES.map {|t| [ t.label, t.type ]}
  end
end
