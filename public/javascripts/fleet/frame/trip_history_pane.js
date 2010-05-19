/**
 * Fleet.Frame.TripHistoryPane
 *
 * Represents the overlay pane the user sees while selecting a trip. This is
 * a banner/bar across the top of the map.
 */
var Fleet = Fleet || {};
Fleet.Frame = Fleet.Frame || {};
Fleet.Frame.TripHistoryPane = (function(TripHistoryPane, Fleet, $) {
  var width = 220,
      pane,
      content,
      progress,
      trip = null,
      init = false;
  
  /**
   * init()
   *
   * Create and prepare the Geofence Edit pane.
   */
  TripHistoryPane.init = function() {
    if (init) {
      return TripHistoryPane;
    }
    
    // Create the geofence edit pane
    $('#frame').before('<div id="trip_history_pane"><div class="date"><input type="text" id="trip_history_date" size="10" maxlength="10"/></div></div>');
    
    // Store a permanent reference to the pane
    pane = $('#trip_history_pane');
    
    // Add a Date Picker for the trip history date
    $('#trip_history_date').datepicker();
    
    // A reference to our content
    //content = pane.children('.content');
    
    // The player progress bar
    /*progress = $('<div class="progress"></div>').appendTo(content).slider({
      min: 0,
      max: 10,
      range: 'min',
      slide: TripHistoryPane.slide
    });*/
    
    init = true;
    return TripHistoryPane;
  };
  
  /**
   * initPane(html)
   *
   * Replace the pane's content with the given HTML.
   */
  TripHistoryPane.initPane = function(html) {
    if (html) {
      content.html(html);
      
      // Hack - select the ellipse if it's a new geofence
      if ($('#shapeChooser input').val() == '') {
        $('#shapeChooser a:first').addClass('selected');
        $('#shapeChooser input').val(0);
      }
    }
    
    return TripHistoryPane;
  };
  
  /**
   * open()
   *
   * Open the trip history pane.
   */
  TripHistoryPane.open = function() {
    pane.slideDown(400, function() {
      Fleet.Frame.resize();
    });
    
    return TripHistoryPane;
  };
  
  /**
   * close()
   *
   * Close the trip history pane.
   */
  TripHistoryPane.close = function() {
    pane.slideUp(400, function() {
      Fleet.Frame.resize();
    });
    
    return TripHistoryPane;
  };
  
  /**
   * trip()
   * trip(trip)
   *
   * Initializes the trip player to display the passed JSON trip object. Call
   * without any arguments to reset the player.
   */
  TripHistoryPane.trip = function(o) {
    var idx, num, points;
    
    if (o) {
      trip = o;
      
      pane.find('h4').text(trip.legs[0].displayable_points[0].time_of_day);
      pane.find('.subheader').text(trip.miles + ' miles over ' + prettyTripDuration(trip.duration));
      
      for(idx = 0, points = 0, num = trip.legs.length; idx < num; idx++) {
        points += trip.legs[idx].displayable_points.length;
      }
      
      progress.slider('option', 'max', points - 1).slider('value', 0);
    } else {
      trip = null;
      
      pane.find('h4').text('');
      pane.find('.subheader').text('');
      progress.slider('option', 'max', 10);
    }
    
    return TripHistoryPane;
  };
  
  /**
   * slide()
   *
   * Move to the appropriate trip point, based on the new position of the trip
   * progress slider.
   */
  TripHistoryPane.slide = function(event, ui) {
    Fleet.Controller.tripProgress(ui.value);
    
    return true;
  };
  
  /* Private Functions */
  
  function prettyTripDuration(seconds) {
    if (seconds < 60) {
      return seconds + ' seconds';
    } else if (seconds < 120) {
      return '1 minute';
    } else {
      return Math.floor(seconds / 60) + ' minutes';
    }
  }
  
  return TripHistoryPane;
}(Fleet.Frame.TripHistoryPane || {}, Fleet, jQuery));
