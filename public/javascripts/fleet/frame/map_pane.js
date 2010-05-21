/**
 * Fleet.Frame.MapPane
 *
 * Represents a map pane within our resizable frame. Once initialized, the map
 * will be available for display and hooked up for resizing.
 */
var Fleet = Fleet || {};
Fleet.Frame = Fleet.Frame || {};
Fleet.Frame.MapPane = (function(MapPane, Frame, Fleet, $) {
  var pane,
      container,
      map,
      popup,
      collections,
      originalEventManagerTrigger,
      eventManagerRunning = false,
      clearListenersQueue = [],
      init = false;
  
  MapPane.map = null;
  MapPane.mq = null;
  
  /**
   * init()
   *
   * Create the MapQuest map holder, initialize MapQuest, and hook up resize
   * handlers.
   */
  MapPane.init = function() {
    if (init) {
      return MapPane;
    }
    
    // Create the map pane
    $('#frame').append('<div id="map_pane"><div class="mapContainer"><div class="map"></div></div></div>');
    
    // #map_pane: our top-level "pane" within the frame
    pane = $('#map_pane');
    
    // .mapContainer: has our padding and any other necessary styling
    container = pane.children('.mapContainer');
    
    // .map: what MapQuest will create the map in
    map = container.children('.map');
    
    // Our list of MapQuest API "shape collections", which we can use to group points and shapes
    collections = {};
    
    // Create our MoshiMap (initialize MapQuest)
    map.moshiMap().init();
    
    MapPane.map = map;
    MapPane.mq = map.moshiMap().map;
    
    // Intercept MapQuest events for our own (nefarious?) purposes
    originalEventManagerTrigger = MQA.EventManager.trigger;
    MQA.EventManager.trigger = mapPaneEventManagerTrigger;
    
    // Our custom pop-up
    popup = $('<div id="map_popup"><div class="top"></div><div class="content"></div><div class="bottom"></div></div>').appendTo($('#mqtiledmap'));
    
    // Whenever the frame is resized, resize our map as well
    Frame.resize(MapPane.resize);
    MapPane.resize();
    
    init = true;
    return MapPane;
  };

  /**
   * resize()
   *
   * If the main frame has been resized, adjust the map to fit the new size.
   * Can be called manually to force a resize.
   */
  MapPane.resize = function() {
    var newWidth = container.width();
    var newHeight = container.height();
    
    map.width(newWidth)
       .height(newHeight)
       .moshiMap().resizeTo(newWidth, newHeight);
    
    return MapPane;
  };

  /**
   * open()
   *
   * Display the map pane. Triggers an automatic resize.
   */
  MapPane.open = function() {
    pane.show();
    
    return MapPane.resize();
  };

  /**
   * close()
   *
   * Hide the map pane.
   */
  MapPane.close = function() {
    pane.hide();
    
    return MapPane;
  };
  
  /**
   * slide(newPadding, callback)
   *
   * "Slide" the map pane to the new padding provided. Passing 0 would expand
   * the map pane to the full size of the frame. Passing 250 would shrink (or
   * expand) the map as necessary so that 250px on the left was available for
   * a sidebar.
   *
   * If provided, the callback function will be called after the resize.
   *
   * Change 5/10/2010 - This function no longer "animates" at all, it just
   * immediately resizes the map to the desired size.
   *
   * TODO: Can this function "pause" while MapQuest loads new tiles, so bg
   * color doesn't show through during the resize?
   */
  MapPane.slide = function(newPadding, callback) {
    var oldPadding = parseInt(container.css('padding-left'));
    
    if (newPadding > oldPadding) {
      container.css('paddingLeft', newPadding);
      MapPane.resize();
      
      if ($.isFunction(callback)) {
        callback();
      }
    } else if (newPadding < oldPadding) {
      container.css('paddingLeft', newPadding);
      MapPane.resize();
      
      if ($.isFunction(callback)) {
        callback();
      }
    }
    
    return MapPane;
  };
  
  /**
   * collection(name)
   *
   * Return the shape collection with the given name. Missing or null names will
   * return the "default" collection.
   *
   * collection(collection)
   *
   * Returns the collection passed in. Exists only for consistency.
   */
  MapPane.collection = function(o) {
    var c;
    
    if (typeof(o) == 'object') {
      if (!collections[o.getName()]) {
        collections[o.getName()] = o;
      }
      
      return o;
    } else {
      o = o || 'default';
      
      c = collections[o];
      if (!c) {
        c = collections[o] = new MQA.ShapeCollection();
        c.setName(o);
      }
    
      return c;
    }
  };
  
  /**
   * showCollection(name)
   * showCollection(collection)
   *
   * Show the given collection on the map. Can be called with a collection name
   * or a collection object.
   */
  MapPane.showCollection = function(o) {
    if (typeof(o) == 'string') {
      o = MapPane.collection(o);
    }
    
    map.moshiMap().map.addShapeCollection(o);
    
    return o;
  };
  
  /**
   * hideCollection(name)
   * hideCollection(collection)
   *
   * Hide the given collection on the map. Can be called with a collection name
   * or a collection object.
   */
  MapPane.hideCollection = function(o) {
    if (typeof(o) != 'string') {
      o = o.getName();
    }
    
    map.moshiMap().map.removeShapeCollection(o);
    
    return o;
  };

  /**
   * removeCollection(name)
   * removeCollection(collection)
   *
   * Hide the collection on the map (remove from DOM) then remove all the objects in
   * the collection (MQ javascript objs)
   */
  MapPane.removeCollection = function(o) {
    if (typeof(o) != 'string') {
      o = o.getName();
    }

    map.moshiMap().map.removeShapeCollection(o);
    MapPane.collection(o).removeAll();
  };
  
  /**
   * addPoint(latitude, longitude, options)
   *
   * Add a point at the given latitude and longitude, then returns the new
   * point object. Optionally, pass a hash of options containing one
   * or more of:
   *   icon
   *   size
   *   iconOffset
   *   title
   *   description
   *   label
   *   reference
   *   collection
   */
  MapPane.addPoint = function(latitude, longitude, options) {
    options = options || {};
    
    var mqPoi = new MQA.Poi(new MQA.LatLng(latitude, longitude));
    var collection = MapPane.collection(options.collection);
    
    if (options.icon) {
      mqPoi.setValue('icon', new MQA.Icon(options.icon, options.size[0], options.size[1]));
      mqPoi.setValue('iconOffset', new MQA.Point(options.offset[0], options.offset[1]));
      mqPoi.setValue('shadow', new MQA.Icon('/images/blank.gif'));
    }

    if (options.title) {
      mqPoi.setValue('rolloverEnabled', true);
      mqPoi.setValue('infoTitleHTML', options.title);
    }

    if (options.description) {
      mqPoi.setValue('infoContentHTML', options.description);
    }

    if (options.label) {
      mqPoi.setValue('labelText', options.label);
      mqPoi.setValue('labelClass', 'mapLabel');
      mqPoi.setValue('labelVisible', false);
    }
    
    if (options.reference) {
      mqPoi.reference = options.reference;
    }
    
    collection.add(mqPoi);

    return mqPoi;
  };
  
  /**
   * removePoint(point)
   * removePoint(point, collection)
   *
   * Remove a point object from the given collection. If the collection is not
   * provided, will attempt to remove the point from the default collection.
   */
  MapPane.removePoint = function(point, collection) {
    collection = MapPane.collection(collection);
  
    if (collection.contains(point)) {
      collection.removeItem(point);
    }
    
    return point;
  };
  
  /**
   * addShape(type, coordinates)
   * addShape(type, coordinates, options)
   *
   * Add a shape to the map given the type and coordinates. The type should be
   * one of Geofence.ELLIPSE, Geofence.RECTANGLE, Geofence.ELLIPSE. The length
   * of the coordinates array depends on the type of shape being created.
   *
   * Optionally, pass a hash of options containing one or more of:
   *   reference
   *   collection
   */
  MapPane.addShape = function(type, coordinates, options) {
    if (coordinates.length == 0) {
      return null;
    }
  
    options = options || {};
    
    var mqShape = MapPane.Geofence.buildShape(type, coordinates);
    var collection = MapPane.collection(options.collection);
    
    if (options.reference) {
      mqShape.reference = options.reference;
    }
    
    collection.add(mqShape);
    
    return mqShape;
  };
  
  /**
   * newShape(options)
   *
   * Add a new shape to the map in the center of the viewable area. Optionally,
   * pass a hash of options containing one or more of:
   *   reference
   *   collection
   */
  MapPane.newShape = function(options) {
    options = options || {};
    
    var coordinates = [],
        centerX = MapPane.map.width() / 2,
        centerY = MapPane.map.height() / 2,
        height = centerY * 0.25,
        tl = MapPane.mq.pixToLL(new MQA.Point(centerX - height, centerY - height)),
        br = MapPane.mq.pixToLL(new MQA.Point(centerX + height, centerY + height));
    
    coordinates = [
      {latitude: tl.lat, longitude: tl.lng},
      {latitude: br.lat, longitude: br.lng}
    ];
    
    /*
      Do we let the user pick the geofence type BEFORE we show it? If so, we'll
      need this code as well. Commented out for now.
    
    if(this.model.getType() == Geofence.POLYGON) {
      var tr = MoshiMap.moshiMap.map.pixToLL(new MQA.Point(centerX+100, centerY-100)),
          bl = MoshiMap.moshiMap.map.pixToLL(new MQA.Point(centerX-100, centerY+100));

      coords.splice(1, 0, [tr.lat, tr.lng]);
      coords.push([bl.lat, bl.lng]);
    }
    
    */
    
    var mqShape = MapPane.Geofence.buildShape(MapPane.Geofence.ELLIPSE, coordinates);
    var collection = MapPane.collection(options.collection);
    
    if (options.reference) {
      mqShape.reference = options.reference;
    }
    
    collection.add(mqShape);
    
    return mqShape;
  };
  
  /**
   * removeShape(shape)
   * removeShape(shape, collection)
   *
   * Remove a shape object from the given collection. If the collection is not
   * provided, will attempt to remove the shape from the default collection.
   */
  MapPane.removeShape = function(shape, collection) {
    collection = MapPane.collection(collection);
  
    if (collection.contains(shape)) {
      collection.removeItem(shape);
    }
    
    return shape;
  };
  
  /**
   * pan(poi)
   *
   * Pan the map to the location of the given MapQuest point object.
   *
   * pan(latitude, longitude)
   *
   * Pan the map to the given latitude and longitude.
   */
  MapPane.pan = function(a, b) {
    if (typeof(a) == 'object') {
      map.moshiMap().map.panToLatLng(a.latLng);
    } else {
      map.moshiMap().map.panToLatLng(new MQA.LatLng(a, b));
    }
    
    return MapPane;
  };
  
  /**
   * center()
   *
   * Return the center of the currently displayed map in lat & long.
   */
  MapPane.center = function() {
    return map.moshiMap().map.getCenter();
  };
  
  /**
   * bestFit(shape)
   * bestFit(list)
   * bestFit(collection)
   *
   * Given a list of MQA.LatLng objects, center and zoom the map to show them.
   * Can be passed as an array of objects or as an MQLatLngCollection.
   *
   * Alternately, pass an MQA.Shape object, and the shape's points will be
   * used, or pass an entire MQA collection to use its points as a set.
   */
  MapPane.bestFit = function(list) {
    // Handle a passed collection
    if (list.collectionName) {
      var idx, num, t;
      
      for(idx = 0, num = list.getSize(), t = []; idx < num; idx++) {
        t.push(list.getAt(idx).getLatLng());
      }
      
      list = t;
    }
    
    // Handle a passed shape
    if (list.getShapePoints) {
      list = list.getShapePoints();
    }
    
    // Handle a passed "shape array" (not yet a real array)
    if (list.getM_Items) {
      list = list.getM_Items();
    }
    
    map.moshiMap().map.bestFitLL(list, false); // , minZoomLevel, maxZoomLevel
    
    return MapPane;
  };
  
  /**
   * popup()
   * popup(point)
   * popup(point, html)
   *
   * Display the popup info window over the given point. If no arguments are
   * given or the first argument is false, the popup will be hidden. Send
   * an optional second argument to update the HTML in the popup window.
   */
  MapPane.popup = function(point, html) {
    if (!point) {
      // restore any z-index fixes
      popup.parent('div').css('z-index',90);
      popup.hide();
      popup.appendTo('body');
    } else {
      if (html) {
        popup.children('.content').html(html);
      }
      
      //popup.css('left', $(point.shape).position().left);
      //popup.css('top', $(point.shape).position().top);
      popup.appendTo(point.shape);

      // fix z-index issues by making it last
      $(point.shape).css('z-index', 95);

      popup.show();
      popup.css('top', -(popup.height() - 2));
    }
    
    return point;
  };
  
  /**
   * enableDragging()
   *
   * Turn on map dragging. Allows the user to pan the map by dragging it.
   */
  MapPane.enableDragging = function() {
    MapPane.mq.enableDragging(true);
  };
  
  /**
   * disableDragging()
   *
   * Turn off map dragging. Used to prevent the map from panning while
   * dragging a geofence shape.
   */
  MapPane.disableDragging = function() {
    MapPane.mq.enableDragging(false);
  };
  
  /**
   * clearListeners(object, eventType)
   *
   * This method takes an object and an event type string, the same arguments
   * as the method it is wrapping (MQA.EventManager.clearListeners). Unlike
   * the original, it is safe to call this version from inside a MapQuest
   * callback.
   */
  MapPane.clearListeners = function(object, eventType) {
    // Yes, this is TOTALLY TURNED OFF RIGHT NOW... That was the easiest
    // way to fix IE7. Should be revisited when fixing memory leaks.
  
    /*if (eventManagerRunning) {
      clearListenersQueue.push([object, eventType]);
    } else {
      MQA.EventManager.clearListeners(object, eventType);
    }*/
  };
  
  /* Private Functions */

  function mapPaneEventManagerTrigger(object, eventType, mqEvent) {
    // This function deserves special attention, as it intercepts all calls to
    // the normal MQA.EventManager.trigger function. If these events are
    // mishandled, it could prevent the user from panning or zooming the map at
    // all, so be careful not to prevent event bubbling.
    
    if (mqEvent.eventName == 'MQA.Poi.mouseOver') {
      Fleet.Controller.hoverPoint.call(object, true);
    } else if (mqEvent.eventName == 'MQA.Poi.mouseOut') {
      Fleet.Controller.hoverPoint.call(object, false);
    } else if (mqEvent.eventName == 'MQA.Poi.click') {
      Fleet.Controller.focusPoint.call(object);
    }
    
    // Call the normal Event Manager trigger, passing in the original context and parameters.
    eventManagerRunning = true;
    var retValue = originalEventManagerTrigger.call(this, object, eventType, mqEvent);
    eventManagerRunning = false;
    
    // Handle any queued clearListeners calls
    while(clearListenersQueue.length > 0) {
      var c = clearListenersQueue.pop();
      MQA.EventManager.clearListeners(c[0], c[1]);
    }
    
    return retValue;
  }
  
  return MapPane;  
}(Fleet.Frame.MapPane || {},
  Fleet.Frame,
  Fleet,
  jQuery));
