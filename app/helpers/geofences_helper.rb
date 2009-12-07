module GeofencesHelper
  def geofences_for_json
    @geofences.to_json(:methods => [:device_ids])
  end

  GEOFENCE_TYPES = {
    Geofence::Type::ELLIPSE => "Ellipse",
    Geofence::Type::RECTANGLE => "Rectangle",
    Geofence::Type::POLYGON => "Polygon"
  }.freeze unless defined?(GEOFENCE_TYPES)

  def geofence_type(geofence)
    GEOFENCE_TYPES[geofence.geofence_type]
  end
end
