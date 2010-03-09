module ReportCardHelper
  def expandable?(group)
    !group.leaf? || group.devices.any?
  end

  # Figure out what the "grade" of the current value is
  # and output an appropriate status icon
  # By default, will not print "green", pass in a 4th parameter
  # to print a green dot
  def status_icon(group, key, value, days, options = {})
    show_green = options.delete(:show_green) || false

    grade =
      case group.grade(key, value, days)
      when Group::Grade::FAIL
        :red
      when Group::Grade::WARN
        :yellow
      when Group::Grade::PASS
        show_green ? :green : nil
      end

    if grade
      content_tag :div, {:class => "status"}.merge(options) do
        image_tag "grade/#{grade}.png"
      end
    end
  end
end
