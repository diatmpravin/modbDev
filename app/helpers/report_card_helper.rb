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
      image_tag "grade/#{image}.png"
      # content_tag :div, {:class => "status"}.merge(options) do
      #   image_tag "grade/#{image}.png"
      # end
    end
  end

  def group_report(group)
    if group.is_a?(Device)
      VehicleReportCard.new(current_user, :device => group, :range => {:type => @range_type}).run
    else
      GroupReportCard.new(current_user, :group => group, :range => {:type => @range_type}).run 
    end
  end

  def operating_time(seconds)
    [seconds/3600, seconds/60 % 60].map{|t| t.to_s.rjust(2,'0')}.join(':')
  end

  def grade_class(data, field, options = {})
    return '' unless data[:duration] > 0

    grade_only = options.delete(:grade_only) || false

    g = data[:report_card][field]
   
    if (grade_only && !g.nil?) 
      g + "_only"
    else
      g == "pass" ? "" : g
    end
  end

  def field(data, name)
    return '-' unless data[:duration] > 0

    return 'err' unless data[name] != nil

    case name
    when :miles then "%.1f" % data[name]
    when :mpg then "%.1f" % data[name]
    when :first_start then operating_time(data[name].to_i)
    when :last_stop then operating_time(data[name].to_i)
    when :duration then operating_time(data[name])
    else data[name]
    end
  end

end
