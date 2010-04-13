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
      confirmRemoveDialog,
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
    $('#landmark_pane li').live('click', function() {
      Fleet.Controller.focus.call(this);
    });
    
    // User can edit a landmark
    $('#landmark_pane a.edit').live('click', function() {
      Fleet.Controller.edit.call(this);
    });
    
    // User can remove a landmark
    $('#landmark_pane a.delete').live('click', function() {
      Fleet.Controller.remove.call(this);
    });
    
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
        '<span class="checkbox"></span>' +
        '<a href="#remove" class="delete hover-only" title="Remove Landmark">Remove</a>' +
        '<a href="#edit" class="edit hover-only" title="Edit Landmark">Edit</a>' +
        landmarks[idx].name + '</li>';
        //'<span class="checkbox"> </span></li>';
    }
    
    list.html(html);
    
    return LandmarkPane;
  };
  
  /**
   * showLandmark(landmark)
   *
   * Take the given landmark and either update its existing row or add
   * it to the list.
   */
  LandmarkPane.showLandmark = function(landmark) {
    var li = $('#landmark_' + landmark.id);
    
    if (li.length > 0) {
      li.html('<a href="#remove" class="delete hover-only" title="Remove Landmark">Remove</a>' +
        '<a href="#edit" class="edit hover-only" title="Edit Landmark">Edit</a>' +
        landmark.name + '</li>');
    } else {
      // There are PROBABLY better places to put this brand new landmark than at the bottom of the list -- but where?!?   \(o_o)/
      list.append('<li id="landmark_' + landmark.id + '">' +
        '<a href="#remove" class="delete hover-only" title="Remove Landmark">Remove</a>' +
        '<a href="#edit" class="edit hover-only" title="Edit Landmark">Edit</a>' +
        landmark.name + '</li>');
    }
  
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
  
  /**
   * editEnabled(bool)
   *
   * Set edit-enabled to true or false (false by default). 
   */
  LandmarkPane.editEnabled = function(bool) {
    if (bool) {
      pane.addClass('edit-enabled');
    } else {
      pane.removeClass('edit-enabled');
    }
  
    return LandmarkPane;
  };
  
  /**
   * getSelections()
   *
   * Return all the selected/active landmarks.
   */
  LandmarkPane.getSelections = function() {
    var selections = [];

    list.find('li.active').each (function () {
      id = $(this).attr('id');
      id = id.substring(id.lastIndexOf('_') + 1);
      selections.push(id);
    });

    return selections;
  };

  return LandmarkPane;
}(Fleet.Frame.LandmarkPane || {}, Fleet, jQuery));
