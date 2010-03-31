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
      map;
  
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
