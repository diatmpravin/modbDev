/**
 * Map Pane
 */
if (typeof MapPane == 'undefined') { MapPane = {}; }

/**
 * Initialize a MapQuest map, setup resize handlers.
 */
MapPane.init = function() {
  MapPane.container = q('#map_pane .mapContainer');
  MapPane.map = MapPane.container.find('.map');
  
  // Create our MoshiMap (MapQuest)
  MapPane.map.moshiMap().init();
  
  // Whenever the frame is resized, resize our map as well
  Frame.resize(MapPane.resize);
  MapPane.resize();
};

/**
 * If the main frame has been resized, adjust the map to fit the new size.
 */
MapPane.resize = function() {
  var newWidth = MapPane.container.width();
  var newHeight = MapPane.container.height();
  
  MapPane.map.width(newWidth)
             .height(newHeight)
             .moshiMap().resizeTo(newWidth, newHeight);
};

/**
 * Show the map. This is PROBABLY being called while the data pane is still
 * overlaid, so we'll take this opportunity to resize as well.
 */
MapPane.open = function() {
  q('#map_pane').show();
  
  MapPane.resize();
};

/**
 * Hide the map. This should be called whenever the data pane is opened
 * again, so that it doesn't cover up any potential device/group editing.
 */
MapPane.close = function() {
  q('#map_pane').hide();
};
