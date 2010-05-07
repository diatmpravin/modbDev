/**
 * Fleet.Frame.MapPane.Geofence
 *
 * All of the functionality in this module technically belongs to MapPane, but
 * there's so much geofence-specific code that it was easiest to encapsulate it
 * here.
 */
var Fleet = Fleet || {};
Fleet.Frame = Fleet.Frame || {};
Fleet.Frame.MapPane = Fleet.Frame.MapPane || {};
Fleet.Frame.MapPane.Geofence = (function(Geofence, $) {
  Geofence.ELLIPSE = 0;
  Geofence.RECTANGLE = 1;
  Geofence.POLYGON = 2;
  
  /**
   * buildShape(type, coordinates)
   *
   * Given a geofence type and a coordinate list, construct a geofence shape and
   * return it. Note that this function does not actually display the shape or
   * add it to any collections.
   *
   * Passing in an empty object will create a "new" geofence shape.
   */
  Geofence.buildShape = function(type, coordinates) {
    var shape = Geofence.shape(type);
    var points = Geofence.points(coordinates);
    shape.setShapePoints(points);
  
    Geofence.setColor(shape, '#FF0000');
    
/*
   
    // TODO pull more into moshimap?
    MoshiMap.moshiMap.geofenceCollection.add(this.shape);

    // Hook up event handling
    var self = this;
    MQA.EventManager.addListener(this.shape, "mousedown", function(e) { self.dragStart(e); });

    this.buildHandles();*/
    
    return shape;
  };
  
  /**
   * shape(type)
   *
   * Return a new MQA Shape object, the type of which is determined by
   * the type (integer) passed as an argument. Defaults to ellipse.
   */
  Geofence.shape = function(type) {
    if (type == Geofence.RECTANGLE) {
      return new MQA.RectangleOverlay();
    } else if (type == Geofence.POLYGON) {
      return new MQA.PolygonOverlay();
    } else {
      return new MQA.EllipseOverlay();
    }
  };
  
  /**
   * points(coordinates)
   *
   * Given a JSON list of [lat, long] coordinates, return a new MQLatLngCollection
   * containing a list of MQA.LatLng points. This collection can be applied to
   * a shape object to display it on the map.
   */
  Geofence.points = function(coordinates) {
    var list = new MQLatLngCollection(),
        idx, num;
    
    // If there are no points, obtain some "default" points.
    if (!coordinates || coordinates.length == 0) {
      coordinates = [];
    }
    
    for(idx = 0, num = coordinates.length; idx < num; idx++) {
      list.add(new MQA.LatLng(coordinates[idx].latitude, coordinates[idx].longitude));
    }
    
    return list;
  }
  
  /**
   * setColor(shape, color)
   *
   * Set the color of the given shape.
   */
  Geofence.setColor = function(shape, color) {
    shape.setColor(color);
    shape.setColorAlpha(0.5);
    shape.setFillColor(color);
    shape.setFillColorAlpha(0.3);
    
    return shape;
  };

  return Geofence;
}(Fleet.Frame.MapPane.Geofence || {}, jQuery));
/*
Fleet.Frame.MapPane = (function(MapPane, Frame, Fleet, $) {
  var pane,
  _getShape: function(type) {
    var shape;
   
  }
  
  /**
   * Build up the geofence in question according to what's in
   * the model.
   *
  build: function() {
    this.shape = this._getShape(this.model.getType());
    this.points = this._buildPoints(this.model.getCoordinates());

    this.shape.setShapePoints(this.points);

    this.setShapeColor("#FF0000");

    // TODO pull more into moshimap?
    MoshiMap.moshiMap.geofenceCollection.add(this.shape);

    // Hook up event handling
    var self = this;
    MQA.EventManager.addListener(this.shape, "mousedown", function(e) { self.dragStart(e); });

    this.buildHandles();
  }
  ,
  buildHandles: function() {
    // Show handles
    if(this.form) {
      this.handleManager.createHandlesOn(this.shape, this.model.getType());
    }
  }
  ,
  */