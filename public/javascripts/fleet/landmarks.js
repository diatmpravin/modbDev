/**
 * Fleet.Landmarks
 *
 * Represents the landmark pane within our resizable frame.
 *
 * Relies on MapPane.
 */
var Fleet = Fleet || {};
Fleet.Landmarks = (function(Landmarks, $) {
  var landmarks = null;
  
  /**
   * load()
   * load(callback)
   *
   * Load all landmarks from the server. If provided, the callback function will
   * be called once the list is loaded. The callback function will be sent an
   * array containing the landmark list.
   */
  Landmarks.load = function(callback) {
    $.getJSON('/landmarks.json', function(json) {
      landmarks = json;
      
      if ($.isFunction(callback)) {
        callback(landmarks);
      };
    });
  };
  
  /**
   * 
  
  return Landmarks;
}(Fleet.Landmarks || {}, jQuery));
