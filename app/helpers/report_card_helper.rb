module ReportCardHelper
  def expandable?(group)
    !group.leaf? || group.devices.any?
  end
end
