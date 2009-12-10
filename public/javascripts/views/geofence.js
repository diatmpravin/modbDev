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

  this.build();

  this.bestFit();
}

Geofence.View.prototype = {
  /**
   * Should be called when the type of geofence needs to be changed.
   */
  geofenceTypeChanged: function() {
    MoshiMap.moshiMap.geofenceCollection.removeItem(this.shape);

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
      MoshiMap.moshiMap.resizeTo(newWidth, newHeight);
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
};
