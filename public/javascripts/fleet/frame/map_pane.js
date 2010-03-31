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
    collections = [];
    
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
   * Add a point
   */
  
  /**
   * Add an individual point to our list of displayed points.
   *
   * @param point   a JSONified Point object
   * @param options an options hash, with the following optional keys:
   *                  icon
   *                  title
   *                  description
   *                  size
   *                  offset
   */
  MoshiMap.prototype.addPoint = function(point, options) {
    var mqLoc = new MQA.LatLng(point.latitude, point.longitude);
    var mqPoi = new MQA.Poi(mqLoc);

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

    mqPoi.moshiPoint = point;
    this.pointCollection.add(mqPoi);

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
