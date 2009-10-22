module GeofencesHelper
  def geofences_for_json
    @geofences.to_json(:methods => [:device_ids])
  end
end
