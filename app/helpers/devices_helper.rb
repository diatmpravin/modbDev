module DevicesHelper
  def devices_for_json
    @devices.to_json(
      :methods => [:color, :connected],
      :include => {
        :position => {
          :methods => :time_of_day
        }
      }
    )
  end
end
