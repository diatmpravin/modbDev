/**
 * A wrapper for adding and initializing a map on the page.
 */
if(typeof Map == "undefined") {
  Map = {};
}

/**
 * The Map.View constructor creates the map container and immediately applies
 * the appropriate styles so that the content pane can "shrink" and scroll
 * correctly.
 */
Map.View = function(options) {
  options = options || {};
  
  // Handle options
  this._contentWidth = options.contentWidth || 500;
  this._hidden = options.hidden || false;
  
  var self = this;
  
  this._resizeHandlers = [];
  
  if (options.container) {
    this._mapContainer = q(options.container);
    this._map = this._mapContainer.find('.map').first();
  } else {
    this._mapContainer = q('<div class="mapContainer"></div>').appendTo(q('#content'));
    this._map = q('<div class="map"></div>').appendTo(this._mapContainer);
  }
  
  this._mapContainer.css('top', '0px');
  this._mapContainer.css('right', '0px');
  this._mapContainer.css('position', 'absolute');
  this._mapContainer.css('overflow', 'hidden');
  this._mapContainer.css('border-left', 'solid 1px #404040');
  
  //q('#layout').css('height','100%');
  //q('#layout').css('overflow','hidden');
  
  q('#content .content').css('overflow','auto');
  q('#content .content').css('width','400px');
  q('#content .content').css('height','200px');
  
  this._contentPaddingY = parseInt(q('#content .content').css('padding-top')) +
    parseInt(q('#content .content').css('padding-bottom'));
  this._contentPaddingX = parseInt(q('#content .content').css('padding-left')) +
    parseInt(q('#content .content').css('padding-right'));
  
  //q('#content').css('overflow','auto');
  
  this._map.moshiMap().init();
  this._map.fitWindow(function(w, h) { self.resize(w, h); });
}

Map.View.prototype = {
  /**
   * Get access to the underlying jquery DOM object of this map.
   */
  getMapElement: function() { return this._map; }
  ,
  /**
   * Various objects on the map might want to do recalculations
   * or redraws when the map resizes. Register a callback that will
   * get executed once the map is fully redrawn.
   */
  registerResizeHandler: function(handler) {
    this._resizeHandlers.push(handler);
  }
  ,
  /**
   * Get current width of the map, in pixels
   */
  width: function() { return this._map.width(); }
  ,
  /**
   * Get current height of the map, in pixels
   */
  height: function() { return this._map.height(); }
  ,
  /**
   * Force a best-fit calculation of the map
   */
  bestFit: function() { MoshiMap.moshiMap.bestFit(); }
  ,
  /**
   * Resize ourselves to fit the new window,
   * and inform MapQuest to also do resizing as necessary
   */
  resize: function(newWidth, newHeight) {
    var self = this;
    
    /*var newHeight = this._mapContainer.parent().height() - 5;
    
    this._map.height(newHeight);
    
    if (MoshiMap.moshiMap) {
      var self = this;
      
      MoshiMap.moshiMap.resizeTo(400, newHeight, function() {
        q.each(self._resizeHandlers, function(i, handler) {
          handler();
        });
      });
    }*/
    
    /*if(this._sidebar != undefined) {
      newWidth = newWidth - this._sidebar.outerWidth();
    }

    newHeight = Math.max(425, newHeight);

    this._map.width(newWidth);
    this._map.height(newHeight);

    if (MoshiMap.moshiMap) {
      var self = this;

      MoshiMap.moshiMap.resizeTo(newWidth, newHeight, function() {
        q.each(self._resizeHandlers, function(i, handler) {
          handler();
        });
      });
    }*/
    
    var mapWidth = newWidth - this._contentWidth;
    var mapHeight = newHeight - 30;
    
    var contentWidth = this._contentWidth - this._contentPaddingX;
    var contentHeight = mapHeight - this._contentPaddingY;
    
    this._map.width(mapWidth)
    this._map.height(mapHeight);
    q('#content .content').width(contentWidth)
    q('#content .content').height(contentHeight);
    
    this._map.moshiMap().resizeTo(mapWidth, mapHeight);
    /*, function() {
      q.each(self._resizeHandlers, function(i, handler) {
        handler();
      });
    });*/
  }
  ,
  /**
   * Add a point to the map.
   * Takes 
   *  - position: lat / long
   *  - options: 
   *
   */
  addPoint: function(point, options) {
    MoshiMap.moshiMap.addPoint(point, options);
  }
  ,
  /**
   * Remove all points from the map
   */
  removePoints: function() {
    MoshiMap.moshiMap.clearPoints();
  }
}
