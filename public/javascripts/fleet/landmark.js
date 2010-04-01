/**
 * Fleet.Frame.LandmarkPane
 *
 * Represents the landmark pane within our resizable frame.
 *
 * Relies on MapPane.
 */
var Fleet = Fleet || {};
Fleet.Frame = Fleet.Frame || {};
Fleet.Frame.LandmarkPane = (function(LandmarkPane, $, MapPane) {
  var pane,
      list,
      landmarks = null;
  
  /**
   * init()
   *
   * Create and prepare the Landmark pane.
   */
  LandmarkPane.init = function() {
    // Create the landmark pane
    $('#frame').append('<div id="landmark_pane"><ol></ol></div>');
    
    // Store a permanent reference to the pane
    pane = $('#landmark_pane');
    
    // Our list of landmarks
    list = pane.children('ol');
    
    return LandmarkPane;
  };
  
  /**
   * loadLandmarks()
   *
   */
  LandmarkPane.loadLandmarks = function() {
    $.getJSON('/landmarks.json', function(json) {
      var idx, num, html;
      
      landmarks = json;
      
      for(idx = 0, num = landmarks.length, html = ''; idx < num; idx++) {
        html += '<li id="landmark_' + landmarks[idx].id + '">' + landmarks[idx].name + '</li>';
      }
    
      list.append(html);
    });
    
    return LandmarkPane;
  };
  
  /**
   * Do something
   */
  LandmarkPane.showLandmarksOnMap = function() {
    var idx, num,
        collection = MapPane.collection('landmarks');
    
    for(idx = 0, num = landmarks.length; idx < num; idx++) {
      if (!landmarks[i].poi) {
        landmarks[i].poi = MapPane.addPoint(landmarks[i].latitude, landmarks[i].longitude, {
          collection: collection,
          reference: landmarks[i]
        });
      }
    }
  };
  
  /**
   * Edit
   */
  LandmarkPane.edit = function() {
    
    
    return false;
  };
  
  return LandmarkPane;
}(Fleet.Frame.LandmarkPane || {}, jQuery, Fleet.Frame.MapPane));
