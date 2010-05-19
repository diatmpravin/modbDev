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
    $('#frame').before('<div id="trip_history_pane"></div>');
    
    // Store a permanent reference to the pane
    pane = $('#trip_history_pane');
    pane.append('<div class="date"><input type="text" id="trip_history_date" size="10" maxlength="10"/></div><div class="trips"></div>');
    
    // Add a Date Picker for the trip history date
    $('#trip_history_date').datepicker().change(function() {
      Fleet.Controller.updateTripList.call(this);
    });
    
    // When created, default to today's date.
    $('#trip_history_date').val(browserDate());

    // Clicking trips in the history bar will display them on the map
    $('#trip_history_pane .trips span').live('click', function() {
      Fleet.Controller.viewTrip.call(this);
    });
    
    init = true;
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
   * trips()
   * trips(trips)
   *
   * Initializes the trip history pane to display the given list of trips
   * (pass it an array of JSON objects). Call without any arguments to clear
   * the list of trips.
   */
  TripHistoryPane.trips = function(o) {
    var idx, num, t;
    
    pane.find('.trips').empty();
    
    if (o) {
      for(idx = 0, num = o.length; idx < num; idx++) {
        t = $('<span id="trip_' + o[idx].id + '"></span>').appendTo(pane.find('.trips'));
        
        t.css('width', (Math.round(o[idx].duration * 100 / 864) / 100) + '%');
        t.css('left', (Math.round(minutesIntoDay(o[idx].start) * 100 / 14.4) / 100) + '%');
      }
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
  
  function browserDate() {
    var date = new Date(),
        day = date.getDate(),
        month = date.getMonth(),
        year = date.getFullYear();
    
    return (month < 10 ? '0' : '') + month + '/' +
           (day < 10 ? '0' : '') + day + '/' +
           year;
  }
  
  function minutesIntoDay(rubyTime) {
    var fields = rubyTime.substring(11, 19).split(':');
    
    return parseInt(fields[0]) * 60 + parseInt(fields[1]);
  }
  
  return TripHistoryPane;
}(Fleet.Frame.TripHistoryPane || {}, Fleet, jQuery));
