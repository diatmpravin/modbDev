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
Fleet.Frame.MapPane.Geofence = (function(Geofence, MapPane, Fleet, $) {
  Geofence.ELLIPSE = 0;
  Geofence.RECTANGLE = 1;
  Geofence.POLYGON = 2;
  
  var draggingShape = null,
      dragOffset = null;
  
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
  
  /**
   * dragShapeStart(shape, mqEvent)
   *
   * Prepare for the geofence shape to be dragged by the user. Passed the shape
   * that will be dragged and the mqEvent representing the mouse-down event.
   */
  Geofence.dragShapeStart = function(shape, mqEvent) {
    var idx, num, xy;
    
    draggingShape = shape;
    
    // Prevent the map from moving while geofence is moving
    MapPane.disableDragging();
    
    // Setup jQuery events for mouse move and mouse up
    MapPane.map.bind('mousemove.geofence', Geofence.dragShape)
               .bind('mouseup.geofence', Geofence.dragShapeEnd);
    
    // Now do some magic -- before mouse moves, save the difference in pixels
    // between each point and the mouse cursor. This allows us to recreate the
    // same shape in a different location.
    var clientX = mqEvent.domEvent.clientX - MapPane.map.position().left - $('#mqtiledmap').position().left,
        clientY = mqEvent.domEvent.clientY - MapPane.map.position().top - $('#mqtiledmap').position().top;
    
    dragOffset = [];
    for(idx = 0, num = draggingShape.getShapePoints().getSize(); idx < num; idx++) {
      xy = MapPane.mq.llToPix(draggingShape.getShapePoints().getAt(idx));
      dragOffset.push([
        xy.x - clientX, xy.y - clientY
      ]);
    }
    //for(var i = 0; i < Geofences.fence.pois.length; i++) {
      //Geofences.fence.pois[i].setValue('visible', false);
    //}
    
    return false;
  };
  
  /**
   * dragShape(event)
   *
   * Handle a shape being dragged. Passed a jQuery event.
   */
  Geofence.dragShape = function(event) {
    var idx, num;
    var clientX = event.clientX - MapPane.map.position().left - $('#mqtiledmap').position().left,
        clientY = event.clientY - MapPane.map.position().top - $('#mqtiledmap').position().top;
    
    var coll = new MQA.LatLngCollection();
    
    for(var idx = 0, num = dragOffset.length; idx < num; idx++) {
      coll.add(MapPane.mq.pixToLL(new MQA.Point(
        dragOffset[idx][0] + clientX,
        dragOffset[idx][1] + clientY
      )));
    }
    
    draggingShape.setShapePoints(coll);
    
    return false;
  };
  
  /**
   * dragShapeEnd(event)
   *
   * Handle the user letting go of a dragged shape. Passed a jQuery event.
   */
  Geofence.dragShapeEnd = function(event) {
    // "Simulate" one last drag event to get the current position
    Geofence.dragShape(event);
    
    // Re-enable map panning
    MapPane.enableDragging();
    MapPane.map.unbind('mousemove.geofence')
               .unbind('mouseup.geofence');
    
    Fleet.Controller.dragShape();
    //this.buildHandles();
    
    return false;
  };

  /**
   * convertShapeCoordinates(mqShape, newType)
   *
   * Return new shape coordinates for the given type, based on the coordinates
   * of the current shape.
   */
  Geofence.convertShapeCoordinates = function(mqShape, newType) {
    var idx, num,
        corners = [360, 360, -360, -360],
        newCoords = [],
        points = mqShape.getShapePoints();
    
    for(idx = 0, num = points.getSize(); idx < num; idx++) {
      var p = points.getAt(idx);
      if (p.lat < corners[0]) { corners[0] = p.lat; }
      if (p.lng < corners[1]) { corners[1] = p.lng; }
      if (p.lat > corners[2]) { corners[2] = p.lat; }
      if (p.lng > corners[3]) { corners[3] = p.lng; }
    }
    
    if (newType == Geofence.ELLIPSE || newType == Geofence.RECTANGLE) {
      newCoords = [
        {latitude: corners[0], longitude: corners[1]},
        {latitude: corners[2], longitude: corners[3]}
      ];
    } else {
      newCoords = [
        {latitude: corners[0], longitude: corners[1]},
        {latitude: corners[2], longitude: corners[1]},
        {latitude: corners[2], longitude: corners[3]},
        {latitude: corners[0], longitude: corners[3]}
      ];
    }
    
    return newCoords;
  };
  
  /**
   * 
    /**
   * Called when a handle has been dragged from the HandleManager.
   * Given a point index, and a new LL, reconstruct the shape
   * as necessary
   *
  updateCurrentShape: function(handles, index, ll, poi) {
    var newPoints;

    switch(this.model.getType()) {
      case Geofence.ELLIPSE:
        newPoints = this._updateEllipse(handles, index, ll);
        break;
      case Geofence.RECTANGLE:
        newPoints = this._updateRectangle(handles, index, ll);
        break;
      case Geofence.POLYGON:
        newPoints = this._updatePolygon(handles, index, ll, poi);
        break;
    }

    this.shape.setShapePoints(newPoints);
    this.buildHandles();

    this.updateModel();
  }*/
  
  return Geofence;
}(Fleet.Frame.MapPane.Geofence || {}, Fleet.Frame.MapPane, Fleet, jQuery));
