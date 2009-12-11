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

  this._map = element;
  this._map.moshiMap().init();
  this._map.fitWindow(function(width, height) { self.resize(width, height); });

  this._resizeHandlers = [];
}

Map.View.prototype = {
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
   * Resize ourselves to fit the new window,
   * and inform MapQuest to also do resizing as necessary
   */
  resize: function(newWidth, newHeight) {
    if(this._sidebar != undefined) {
      newWidth = newWidth - this._sidebar.outerWidth();
    }

    newHeight = Math.max(350, newHeight);

    this._map.width(newWidth);
    this._map.height(newHeight);

    if (MoshiMap.moshiMap) {
      var self = this;
      MoshiMap.moshiMap.resizeTo(newWidth, newHeight, function() {
        q.each(self._resizeHandlers, function(handler) {
          handler();
        });
      });
    }
  }
}
