/**
 * View handling of Geofences
 */
if(typeof Geofence == 'undefined') {
  Geofence = {};
}

Geofence.View = function(model, form) {
  var self = this;

  this.model = model;
  this.form = form;

  // TODO This might be something to pull out elsewhere
  this._map = q("#map");
  this._map.moshiMap().init();
  this._map.fitWindow(function(width, height) { self.resize(width, height); });

  this.handleManager = new HandleManager(this);
  this.handleManager.onDragEnd = function(handles, index, ll, poi) {
    self.updateCurrentShape(handles, index, ll, poi);
  }

  this.build();

  this.bestFit();
}

Geofence.View.prototype = {
  /**
   * Should be called when the type of geofence needs to be changed.
   */
  geofenceTypeChanged: function(oldType, newType) {
    MoshiMap.moshiMap.geofenceCollection.removeItem(this.shape);

    this.convertShape(oldType, newType);

    this.build();
    this.bestFit();
  }
  ,
  /**
   * Given a now build geofence, draw it and
   * have the map zoom to the appropriate zoom and location.
   */
  bestFit: function() {
    var tmp = new MQA.ShapeCollection();
    tmp.add(this.shape);
    var bounds = tmp.getBoundingRect();

    if(bounds) {
      MoshiMap.moshiMap.map.bestFitLL([bounds.getUpperLeft(), bounds.getLowerRight()], false, 3);
    }
  }
  ,
  /**
   * Build up the geofence in question according to what's in
   * the model.
   */
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
  /**
   * When geofence type is changed, recalculate the points to be
   * in the area of the old shape so the user isn't surprised by a
   * sudden area change
   */
  convertShape: function(oldType, newType) {
    var corners = [360, 360, -360, -360], newCoords = [];

    for(var i = 0; i < this.shape.shapePoints.getSize(); i++) {
      var p = this.shape.shapePoints.getAt(i);
      if (p.lat < corners[0]) { corners[0] = p.lat; }
      if (p.lng < corners[1]) { corners[1] = p.lng; }
      if (p.lat > corners[2]) { corners[2] = p.lat; }
      if (p.lng > corners[3]) { corners[3] = p.lng; }
    }

    if (newType == Geofence.ELLIPSE || newType == Geofence.RECTANGLE) {
      newCoords = [
        // Lat     , Long
        [corners[0], corners[1]],
        [corners[2], corners[3]]
      ];
    } else {
      newCoords = [
        // Lat     , Long
        [corners[0], corners[1]],
        [corners[2], corners[1]],
        [corners[2], corners[3]],
        [corners[0], corners[3]]
      ];
    }

    this.model.setCoordinates(newCoords);
  }
  ,
  /**
   * Resize ourselves to fit the new window,
   * and inform MapQuest to also do resizing as necessary
   */
  resize: function(newWidth, newHeight) {
    if(this.form != undefined) {
      newWidth = newWidth - this.form.width();
    }

    newHeight = Math.max(350, newHeight);

    this._map.width(newWidth);
    this._map.height(newHeight);

    if (MoshiMap.moshiMap) {
      var self = this;
      MoshiMap.moshiMap.resizeTo(newWidth, newHeight, function() {
        self.buildHandles(); 
      });
    }
  }
  ,
  /**
   * Called when a handle has been dragged from the HandleManager.
   * Given a point index, and a new LL, reconstruct the shape
   * as necessary
   */
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

    if(this.form) {
      this.updateModel();
    }
  }
  ,
  /**
   * Do any pre-handling of the geofence for proper dragging
   */
  dragStart: function(mqEvent) {
    var self = this;
    MoshiMap.moshiMap.disableDragging();
    this._map.bind('mousemove.geofence', function(e) { self.drag(e); });
    this._map.bind('mouseup.geofence', function(e) { self.dragEnd(e); });

    this._dragOffset = [];
    var xy;

    var clientX = mqEvent.domEvent.clientX - this._map.position().left - q('#mqtiledmap').position().left,
        clientY = mqEvent.domEvent.clientY - this._map.position().top - q('#mqtiledmap').position().top;

    for(var i = 0; i < this.shape.shapePoints.getSize(); i++) {
      xy = MoshiMap.moshiMap.map.llToPix(this.shape.shapePoints.getAt(i));
      this._dragOffset[this._dragOffset.length] = [
        xy.x - clientX, xy.y - clientY
      ];
    }

    //for(var i = 0; i < Geofences.fence.pois.length; i++) {
      //Geofences.fence.pois[i].setValue('visible', false);
    //}
  }
  ,
  drag: function(event) {
    var clientX = event.clientX - this._map.position().left - q('#mqtiledmap').position().left,
        clientY = event.clientY - this._map.position().top - q('#mqtiledmap').position().top;

    var coll = new MQA.LatLngCollection();

    for(var i = 0; i < this._dragOffset.length; i++) {
      coll.add(MoshiMap.moshiMap.map.pixToLL(new MQA.Point(
        this._dragOffset[i][0] + clientX,
        this._dragOffset[i][1] + clientY
      )));
    }

    this.shape.setShapePoints(coll);
  }
  ,
  dragEnd: function(event) {
    // One more drag, then unset everything
    this.drag(event);

    this._dragOffset = undefined;

    MoshiMap.moshiMap.enableDragging();
    this._map.unbind('mousemove.geofence');
    this._map.unbind('mouseup.geofence');

    if(this.form) {
      this.updateModel();
      this.buildHandles();
    }
  }
  ,
  /**
   * Set the color of the geofence shape
   */
  setShapeColor: function(color) {
    this.shape.setColor(color);
    this.shape.setColorAlpha(0.5);
    this.shape.setFillColor(color);
    this.shape.setFillColorAlpha(0.3);
  }
  ,
  /**
   * Tell the form that it needs to update it's knowledge of the
   * geofence. For now, that means sending up new points.
   * Data is sent as:
   *
   *   [ [lat, lon], [lat, lon], ...]
   */
  updateModel: function() {
    var coords = [], p;
    for(var i = 0; i < this.shape.shapePoints.getSize(); i++) {
      p = this.shape.shapePoints.get(i);
     coords.push([p.lat, p.lng]);
    }

    this.form.updateModel(coords);
  }
  ,

  /*********
   * Private
   *********/

  _getShape: function(type) {
    var shape;
    switch(type) {
      case Geofence.ELLIPSE:
        shape = new MQA.EllipseOverlay();
        break;
      case Geofence.RECTANGLE:
        shape = new MQA.RectangleOverlay();
        break;
      case Geofence.POLYGON:
        shape = new MQA.PolygonOverlay();
        break;
    }

    return shape;
  }
  ,
  _buildPoints: function(coordinates) {
    var points = new MQLatLngCollection();

    for(var i = 0; i < coordinates.length; i++) {
      points.add(new MQA.LatLng(coordinates[i][0], coordinates[i][1]));
    }

    return points;
  }
  ,
  _updateEllipse: function(handles, index, ll) {
    var points = new MQLatLngCollection(),
        otherPoi = handles[(index + 2) % 4],

        xy1 = MoshiMap.moshiMap.map.llToPix(ll),
        xy2 = MoshiMap.moshiMap.map.llToPix(otherPoi.getLatLng()),

        newxy1 = new MQA.Point((42 * xy1.x - 7 * xy2.x)/35, (42 * xy1.y - 7 * xy2.y)/35),
        newxy2 = new MQA.Point((42 * xy2.x - 7 * xy1.x)/35, (42 * xy2.y - 7 * xy1.y)/35);

    points.add(MoshiMap.moshiMap.map.pixToLL(newxy1));
    points.add(MoshiMap.moshiMap.map.pixToLL(newxy2));

    return points;
  }
  ,
  _updateRectangle: function(handles, index, ll) {
    var points = new MQLatLngCollection(),
        otherPoi = handles[(index + 2) % 4];

    points.add(ll);
    points.add(otherPoi.getLatLng());

    return points;
  }
  ,
  _updatePolygon: function(handles, index, ll, poi) {
    var points = new MQLatLngCollection();

    for(var i = 0; i < this.shape.shapePoints.getSize(); i++) {
      if (i == index) {
        if (poi.coordNew) {
          points.add(this.shape.shapePoints.getAt(i));
        }
        if (!poi.deleting) {
          points.add(poi.getLatLng());
        }
      } else {
        points.add(this.shape.shapePoints.getAt(i));
      }
    }

    return points;
  }
};

HandleManager = function(view) {
  this.view = view;
  this.map = view._map;
  this.shape = null;
  this.handles = [];

  // Callback for handling rebuilding of shapes as needed
  // due to handle changes
  this.onDragEnd = function(handles, index, ll) { };
}

HandleManager.prototype = {
  /**
   * Clear out any old handles from a previous shape
   */
  clearOldHandles: function() {
    for(var i = 0; i < this.handles.length; i++) {
      MoshiMap.moshiMap.tempCollection.removeItem(this.handles[i]);
    }

    this.handles = [];
  }
  ,
  /**
   * Given a new shape, build handles to manipulate the shape
   */
  createHandlesOn: function(shape, type) {
    this.clearOldHandles();

    this.shape = shape;
    this.shapeType = type;
    
    switch(this.shapeType) {
      case Geofence.ELLIPSE:
        this.buildEllipseHandles(shape);
        break;
      case Geofence.RECTANGLE:
        this.buildRectangleHandles(shape);
        break;
      case Geofence.POLYGON:
        this.buildPolygonHandles(shape);
        break;
    }
  }
  ,
  buildEllipseHandles: function(shape) {
    var c = [
      MoshiMap.moshiMap.map.llToPix(shape.shapePoints.getAt(0)),
      MoshiMap.moshiMap.map.llToPix(shape.shapePoints.getAt(1))
    ];
    var xy = [
      new MQA.Point((6 * c[0].x + 1 * c[1].x)/7, (6 * c[0].y + 1 * c[1].y)/7),
      new MQA.Point((6 * c[1].x + 1 * c[0].x)/7, (6 * c[0].y + 1 * c[1].y)/7),
      new MQA.Point((6 * c[1].x + 1 * c[0].x)/7, (6 * c[1].y + 1 * c[0].y)/7),
      new MQA.Point((6 * c[0].x + 1 * c[1].x)/7, (6 * c[1].y + 1 * c[0].y)/7),
    ]
    this._createHandle(MoshiMap.moshiMap.map.pixToLL(xy[0]), true).coordIndex = 0;
    this._createHandle(MoshiMap.moshiMap.map.pixToLL(xy[1]), true).coordIndex = 1;
    this._createHandle(MoshiMap.moshiMap.map.pixToLL(xy[2]), true).coordIndex = 2;
    this._createHandle(MoshiMap.moshiMap.map.pixToLL(xy[3]), true).coordIndex = 3;
  }
  ,
  buildRectangleHandles: function(shape) {
    var c = [
      shape.shapePoints.getAt(0),
      shape.shapePoints.getAt(1)
    ];
    this._createHandle(new MQA.LatLng(c[0].lat, c[0].lng), true).coordIndex = 0;
    this._createHandle(new MQA.LatLng(c[0].lat, c[1].lng), true).coordIndex = 1;
    this._createHandle(new MQA.LatLng(c[1].lat, c[1].lng), true).coordIndex = 2;
    this._createHandle(new MQA.LatLng(c[1].lat, c[0].lng), true).coordIndex = 3;
  }
  ,
  buildPolygonHandles: function(shape) {
    for(var i = 0; i < shape.shapePoints.getSize(); i++) {
      var mqPoi = this._createHandle(shape.shapePoints.getAt(i), true);
      mqPoi.coordIndex = i;
      mqPoi.coordNew = false;
      
      var j = (i+1) % shape.shapePoints.getSize();
      var xy1 = MoshiMap.moshiMap.map.llToPix(shape.shapePoints.getAt(i));
      var xy2 = MoshiMap.moshiMap.map.llToPix(shape.shapePoints.getAt(j));
      var xy3 = new MQA.Point((xy1.x + xy2.x)/2, (xy1.y + xy2.y)/2);
      
      mqPoi = this._createHandle(MoshiMap.moshiMap.map.pixToLL(xy3), false);
      mqPoi.coordIndex = i;
      mqPoi.coordNew = true;
    }
  }
  ,

  /**********
   * Private
   **********/

  /**
   * Create a handle at the given lat/long, and specify if it's a corner
   * handle or not.
   */
  _createHandle: function(ll, isCorner) {
    var self = this, mqPoi = new MQA.Poi(ll);
    if (isCorner) {
      mqPoi.setValue('icon', new MQA.Icon('/images/shape_handle_corner.png', 9, 9));
    } else {
      mqPoi.setValue('icon', new MQA.Icon('/images/shape_handle_edge.png', 9, 9));
    }
    mqPoi.setValue('iconOffset', new MQA.Point(-4, -4));
    mqPoi.setValue('draggable', true);
    mqPoi.setValue('shadow', null);
    MoshiMap.moshiMap.tempCollection.add(mqPoi);
    this.handles[this.handles.length] = mqPoi;

    MQA.EventManager.addListener(mqPoi, 'mousedown', function(e) { self._dragStart(this, e); });
    MQA.EventManager.addListener(mqPoi, 'mouseup', function(e) { self._dragEnd(e); });
    
    return mqPoi;
  }
  ,
  /**
   * Start dragging a handle
   */
  _dragStart: function(handle, mqEvent) {
    var self = this;
    this._nowDragging = handle;
    this.map.bind("mousemove.handle", function(e) { self._drag(e); });
  }
  ,
  /**
   * Dragging a handle
   */
  _drag: function(event) {
    var clientX = event.clientX - this.map.position().left - q('#mqtiledmap').position().left;
    var clientY = event.clientY - this.map.position().top - q('#mqtiledmap').position().top;
    var mqPoi = this._nowDragging;
    
    for(var i = 0; i < this.handles.length; i++) {
      var otherPoi = this.handles[i];
      mqPoi.deleting = false;
      if (otherPoi.coordIndex != mqPoi.coordIndex && !otherPoi.coordNew) {
        var xy = MoshiMap.moshiMap.map.llToPix(otherPoi.getLatLng());
        if (Math.abs(xy.x-clientX) < 6 && Math.abs(xy.y-clientY) < 6) {
          mqPoi.deleting = true;
          break;
        }
      }
    }
  }
  ,
  /**
   * Done dragging a handle, update the shape
   */
  _dragEnd: function(event) {
    var mqPoi = this._nowDragging;
    this.map.unbind("mousemove.handle");

    this.onDragEnd(this.handles, mqPoi.coordIndex, mqPoi.getLatLng(), mqPoi);

    this._nowDragging = null;
  }
};
