/**
 * Fleet.Frame.MapPane
 *
 * Represents a map pane within our resizable frame. Once initialized, the map
 * will be available for display and hooked up for resizing.
 */
var Fleet = Fleet || {};
Fleet.Frame = Fleet.Frame || {};
Fleet.Frame.MapPane = (function(MapPane, $, Frame) {
  var pane,
      container,
      map,
      collections;
  
  /**
   * init()
   *
   * Create the MapQuest map holder, initialize MapQuest, and hook up resize
   * handlers.
   */
  MapPane.init = function() {
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
    
    // Whenever the frame is resized, resize our map as well
    Frame.resize(MapPane.resize);
    MapPane.resize();
    
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
   * collection(name)
   *
   * Return the shape collection with the given name. Missing or null names will
   * return the "default" collection.
   */
  MapPane.collection = function(name) {
    name = name || 'default';
    
    var c = collections[name];
    if (!c) {
      c = collections[name] = new MQA.ShapeCollection();
      c.setName(name);
    }
    
    return c;
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
   * addPoint(latitude, longitude, options)
   *
   * Add a point at the given latitude and longitude. Optionally, pass
   * a hash of options containing one or more of:
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
    var collection = options.collection || MapPane.collection('default');
    
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
   * panToDeviceId(id)
   *
   * Pan the move to the point specified by the given device id.
   */
  MapPane.panToDeviceId = function(id) {
    var point = VehiclesView.lookup[parseInt(id)];
    
    if (point) {
      MoshiMap.moshiMap.map.panToLatLng(point.latLng);
    }
  };
  
  return MapPane;  
}(Fleet.Frame.MapPane || {}, jQuery, Fleet.Frame));
