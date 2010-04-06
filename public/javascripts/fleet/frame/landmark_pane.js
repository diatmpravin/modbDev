/**
 * Fleet.Frame.LandmarkPane
 *
 * Represents the landmark pane within our resizable frame.
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
    
    // User can click to pan
    $('#landmark_pane li').live('click', Fleet.LandmarkController.focus);
    
    // User can edit a landmark
    $('#landmark_pane a.edit').live('click', Fleet.LandmarkController.edit);
    
    // User can remove a landmark
    //$('#landmark_pane a.delete').live('click', Fleet.LandmarkController.);
    
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
      html += '<li id="landmark_' + landmarks[idx].id + '">' +
        '<a href="#remove" class="delete hover-only" title="Remove Landmark">Remove</a>' +
        '<a href="#edit" class="edit hover-only" title="Edit Landmark">Edit</a>' +
        landmarks[idx].name + '</li>';
    }
    
    list.html(html);
    
    return LandmarkPane;
  };
  
  /**
   * open()
   * open(callback)
   *
   * Open the landmark pane. If provided, the callback will be called after
   * the pane is open.
   */
  LandmarkPane.open = function(callback) {
    if ($.isFunction(callback)) {
      pane.animate({width: width}, {
        duration: 400,
        complete: callback
      });
    } else {
      pane.animate({width: width}, {duration: 400});
    }
    
    return LandmarkPane;
  };
  
  /**
   * close()
   * close(callback)
   *
   * Close the landmark pane. If provided, the callback will be called after
   * the pane is closed.
   */
  LandmarkPane.close = function(callback) {
    if ($.isFunction(callback)) {
      pane.animate({width: 0}, {
        duration: 400,
        complete: callback
      });
    } else {
      pane.animate({width: 0}, {duration: 400});
    }
    
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
