/**
 * A map view. This takes care of initializing
 * and running a map on a page.
 */
if(typeof Map == "undefined") {
  Map = {};
}

Map.View = function(element, sidebar) {
  var self = this;

  this._sidebar = sidebar;
  this._resizeHandlers = [];

  this._map = element;
  this._map.moshiMap().init();
  this._map.fitWindow(function(width, height) { self.resize(width, height); });
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
    if(this._sidebar != undefined) {
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
    }
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
