/**
 * Fleet.Frame.GeofencePane
 *
 * Represents the geofence pane within our resizable frame.
 */
var Fleet = Fleet || {};
Fleet.Frame = Fleet.Frame || {};
Fleet.Frame.GeofencePane = (function(GeofencePane, Fleet, $) {
  var width = 280,
      pane,
      list,
      confirmRemoveDialog,
      geofences = null,
      lookup = null,
      init = false;
  
  /**
   * init()
   *
   * Create and prepare the Geofence pane.
   */
  GeofencePane.init = function() {
    if (init) {
      return GeofencePane;
    }
    
    // Create the geofence pane
    $('#frame').append('<div id="geofence_pane"><ol></ol></div>');
    
    // Store a permanent reference to the pane
    pane = $('#geofence_pane');
    
    // Our list of geofences
    list = pane.children('ol');

    // User can click to pan
    $('#geofence_pane li').live('click', function() {
      return Fleet.Controller.focus.call(this);
    });
  
    // User can edit a geofence
    $('#geofence_pane a.edit').live('click', function() {
      return Fleet.Controller.edit.call(this);
    });
    
    // User can remove a geofence
    $('#geofence_pane a.delete').live('click', function() {
      return Fleet.Controller.remove.call(this);
    });
    
    init = true;
    return GeofencePane;
  };
  
  /**
   * showGeofences(geofences)
   *
   * Take the given list of geofences and populate the geofence list. Clears
   * any existing geofence HTML.
   */
  GeofencePane.showGeofences = function(geofences, showSelectAll) {
    var idx, num, html;
 
    html = '';
    if (showSelectAll) {
      html += '<li id="all"><span class="checkbox"></span><b>All</b></li>';
    }

    for(idx = 0, num = geofences.length; idx < num; idx++) {
      html += '<li id="geofence_' + geofences[idx].id + '">' +
        '<span class="checkbox"></span>' +
        '<a href="#remove" class="delete hover-only" title="Remove Geofence">Remove</a>' +
        '<a href="#edit" class="edit hover-only" title="Edit Geofence">Edit</a>' +
        geofences[idx].name + '</li>';
    }
    
    list.html(html);
    
    return GeofencePane;
  };
  
  /**
   * showGeofence(geofence)
   *
   * Take the given geofence and either update its existing row or add
   * it to the list.
   */
  GeofencePane.showGeofence = function(geofence) {
    var li = $('#geofence_' + geofence.id);
    
    if (li.length > 0) {
      li.html('<a href="#remove" class="delete hover-only" title="Remove Geofence">Remove</a>' +
        '<a href="#edit" class="edit hover-only" title="Edit Geofence">Edit</a>' +
        geofence.name + '</li>');
    } else {
      // There are PROBABLY better places to put this brand new geofence than at the bottom of the list -- but where?!?   \(o_o)/
      list.append('<li id="geofence_' + geofence.id + '">' +
        '<a href="#remove" class="delete hover-only" title="Remove Geofence">Remove</a>' +
        '<a href="#edit" class="edit hover-only" title="Edit Geofence">Edit</a>' +
        geofence.name + '</li>');
    }
  
    return GeofencePane;
  };
  
  /**
   * open()
   * open(callback)
   *
   * Open the geofence pane. If provided, the callback will be called after
   * the pane is open.
   */
  GeofencePane.open = function(callback) {
    if ($.isFunction(callback)) {
      pane.animate({width: width}, {
        duration: 400,
        complete: callback
      });
    } else {
      pane.animate({width: width}, {duration: 400});
    }
    
    return GeofencePane;
  };

  /**
   * close()
   * close(callback)
   *
   * Close the geofence pane. If provided, the callback will be called after
   * the pane is closed.
   */
  GeofencePane.close = function(callback) {
    if ($.isFunction(callback)) {
      pane.animate({width: 0}, {
        duration: 400,
        complete: callback
      });
    } else {
      pane.animate({width: 0}, {duration: 400});
    }
    
    return GeofencePane;
  };
  
  GeofencePane.toggleActive = function() {
    var active = $(this).toggleClass('active').hasClass('active');
    /* If this item is the "All" item, then make all selections in the list same as this */
    if (this.id == 'all') {
      list.find('li').toggleClass('active', active);
    }
  };

  /**
   * width()
   *
   * Return the current width of the landmark pane.
   */
  GeofencePane.width = function() {
    return pane.width();
  };
  
  /**
   * editEnabled(bool)
   *
   * Set edit-enabled to true or false (false by default). 
   */
  GeofencePane.editEnabled = function(bool) {
    if (bool) {
      pane.addClass('edit-enabled');
    } else {
      pane.removeClass('edit-enabled');
    }
  
    return GeofencePane;
  };
  
  /**
   * getSelections()
   *
   * Return all the selected/active geofences.
   */
  GeofencePane.getSelections = function() {
    var selections = [];

    list.find('li.active').not('#all').each (function () {
      id = $(this).attr('id');
      id = id.substring(id.lastIndexOf('_') + 1);
      selections.push(id);
    });

    return selections;
  };

  return GeofencePane;
}(Fleet.Frame.GeofencePane || {}, Fleet, jQuery));
