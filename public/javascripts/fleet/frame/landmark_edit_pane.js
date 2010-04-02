/**
 * Fleet.Frame.LandmarkEditPane
 *
 * WORK IN PROGRESS
 * Represents a landmark 
 * Represents the landmark pane within our resizable frame.
 *
 * Relies on MapPane.
 */
var Fleet = Fleet || {};
Fleet.Frame = Fleet.Frame || {};
Fleet.Frame.LandmarkPane = (function(LandmarkPane, Fleet, $) {
  var width = 280,
      pane,
      list,
      landmarks = null,
      lookup = null,
      init = false;
  
  /**
   * init()
   *
   * Create and prepare the Landmark pane.
   */
  LandmarkPane.init = function() {
    if (init) {
      return LandmarkPane;
    }
    
    // Create the landmark pane
    $('#frame').append('<div id="landmark_pane"><ol></ol></div>');
    
    // Store a permanent reference to the pane
    pane = $('#landmark_pane');
    
    // Our list of landmarks
    list = pane.children('ol');
    
    // User can click to edit
    $('#landmark_pane li').live('click', Fleet.LandmarkController.edit);
    
    init = true;
    return LandmarkPane;
  };
  
  /**
   * showLandmarks(landmarks)
   *
   * Take the given list of landmarks and populate the landmark list. Clears
   * any existing landmark HTML.
   */
  LandmarkPane.showLandmarks = function(landmarks) {
    var idx, num, html;
    
    for(idx = 0, num = landmarks.length, html = ''; idx < num; idx++) {
      html += '<li id="landmark_' + landmarks[idx].id + '">' + landmarks[idx].name + '</li>';
    }
    
    list.html(html);
    
    return LandmarkPane;
  };
  
  /**
   * open()
   *
   * Open the landmark pane.
   */
  LandmarkPane.open = function() {
    pane.animate({width: width}, {duration: 400});
    
    return LandmarkPane;
  };
  
  /**
   * close()
   *
   * Close the landmark pane.
   */
  LandmarkPane.close = function() {
    pane.animate({width: 0}, {duration: 400});
    
    return LandmarkPane;
  };
  
  /**
   * width()
   *
   * Return the current width of the landmark pane.
   */
  LandmarkPane.width = function() {
    return pane.width();
  };
  
  return LandmarkPane;
}(Fleet.Frame.LandmarkPane || {}, Fleet, jQuery));
