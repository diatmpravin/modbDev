module ReportCardHelper
  def expandable?(group)
    !group.leaf? || group.devices.any?
  end

  # Figure out what the "grade" of the current value is
  # and output an appropriate status icon
  # By default, will not print "green", pass in a 4th parameter
  # to print a green dot
  def status_icon(grade, options = {})
    show_green = options.delete(:show_green) || false

    image =
      case grade
      when "pass"
        show_green ? "green" : nil
      when "warn"
        "yellow"
      when "fail"
        "red"
      end

    if image
      content_tag :div, {:class => "status"}.merge(options) do
        image_tag "grade/#{image}.png"
      end
    end
  end

  def group_report(group)
    if group.is_a?(Device)
      VehicleSummaryReport.new(current_user, :devices => [group], :range => {:type => @range_type}).tap {|g| g.run}
    else
      #GroupSummaryReport.new(current_user, :group => group, :range => {:type => @range_type}).tap {|g| g.run }
      grc = GroupReportCard.new(group)
      grc.start = Date.yesterday
      grc.end = Date.yesterday
      grc.run
    end
  end
end
