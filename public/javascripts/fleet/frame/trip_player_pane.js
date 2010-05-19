/**
 * Fleet.Frame.TripPlayerPane
 *
 * Represents the overlay pane the user sees while playing a trip.
 */
var Fleet = Fleet || {};
Fleet.Frame = Fleet.Frame || {};
Fleet.Frame.TripPlayerPane = (function(TripPlayerPane, Fleet, $) {
  var width = 220,
      pane,
      content,
      progress,
      init = false;
  
  /**
   * init()
   *
   * Create and prepare the Geofence Edit pane.
   */
  TripPlayerPane.init = function() {
    if (init) {
      return TripPlayerPane;
    }
    
    // Create the geofence edit pane
    $('#frame').append('<div id="trip_player_pane"><h4></h4><div class="subheader"></div><div class="content"></div></div>');
    
    // Store a permanent reference to the pane
    pane = $('#trip_player_pane');
    
    // A reference to our content
    content = pane.children('.content');
    
    // The player progress bar
    progress = $('<div class="progress"></div>').appendTo(content).slider({
      min: 0,
      max: 10,
      range: 'min',
      slide: TripPlayerPane.slide
    });
    
    init = true;
    return TripPlayerPane;
  };
  
  /**
   * initPane(html)
   *
   * Replace the pane's content with the given HTML.
   */
  TripPlayerPane.initPane = function(html) {
    if (html) {
      content.html(html);
      
      // Hack - select the ellipse if it's a new geofence
      if ($('#shapeChooser input').val() == '') {
        $('#shapeChooser a:first').addClass('selected');
        $('#shapeChooser input').val(0);
      }
    }
    
    return TripPlayerPane;
  };
  
  /**
   * open()
   *
   * Open the geofence edit pane.
   */
  TripPlayerPane.open = function() {
    pane.animate({opacity: 0.9, right: 8}, {duration: 400});
    
    return TripPlayerPane;
  };
  
  /**
   * close()
   *
   * Close the landmark edit pane.
   */
  TripPlayerPane.close = function() {
    pane.animate({opacity: 0, right: 0 - (width + 8)}, {duration: 400});
    
    return TripPlayerPane;
  };
  
  /**
   * trip()
   * trip(trip)
   *
   * Initializes the trip player to display the passed JSON trip object. Call
   * without any arguments to reset the player.
   */
  TripPlayerPane.trip = function(o) {
    var idx, num, points;
    
    if (o) {
      pane.find('h4').text(o.legs[0].displayable_points[0].time_of_day);
      pane.find('.subheader').text(o.miles + ' miles over ' + prettyTripDuration(o.duration));
      
      for(idx = 0, points = 0, num = o.legs.length; idx < num; idx++) {
        points += o.legs[idx].displayable_points.length;
      }
      
      progress.slider('option', 'max', points - 1).slider('value', 0);
    } else {
      pane.find('h4').text('');
      pane.find('.subheader').text('');
      progress.slider('option', 'max', 10);
    }
    
    return TripPlayerPane;
  };
  
  /**
   * slide()
   *
   * Move to the appropriate trip point, based on the new position of the trip
   * progress slider.
   */
  TripPlayerPane.slide = function(event, ui) {
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
  
  return TripPlayerPane;
}(Fleet.Frame.TripPlayerPane || {}, Fleet, jQuery));
