if(typeof Geofence == "undefined") {
  Geofence = {}
}

/**
 * Types of supported geofences
 */
Geofence.ELLIPSE = 0;
Geofence.RECTANGLE = 1;
Geofence.POLYGON = 2;

Geofence.Model = function(type, coordinates) {
  this.type = type;
  this.coordinates = coordinates;
}

Geofence.Model.prototype = {
  /**
   * Get / Set the type of geofence
   */
  getType: function() { return this.type; }
  ,
  setType: function(type) { this.type = type; }
  ,
  /**
   * Get / Set the coordinates list
   */
  getCoordinates: function() { return this.coordinates; }
  ,
  setCoordinates: function(coords) { this.coordinates = coords; }
};
