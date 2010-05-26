/**
 * Fleet.MapController
 */
var Fleet = Fleet || {};
Fleet.MapController = (function(MapController, MapPane, VehiclePane, TripHistoryPane, TripPlayerPane, Header, Frame, $) {
  var vehicles = null,
      lookup = null,
      selected_id = null,
      tripVehicle = null,
      trips = [],
      tripLookup = null,
      init = false;
  
  /* Map Tab */
  MapController.tab = 'mapview';
  
  /**
   * init()
   */
  MapController.init = function() {
    if (init) {
      return MapController;
    }
    
    // Define the Map View header
    Header.init().define('map', '<span class="title">Map View</span>');
    
    // Define the Trip History header
    Header.define('history', '<span class="buttons"><button type="button" class="back">Return</button></span><span class="title">Trip History</span>');
    
    init = true;
    return MapController;
  };
  
  /**
   * setup()
   *
   * Prepare all of our panes and setup the vehicle list view.
   */
  MapController.setup = function() {
    MapPane.init().open().showCollection('vehicles');
    VehiclePane.init().open().selectEnabled(false).historyEnabled(true);
    TripHistoryPane.init().close();
    TripPlayerPane.init().close();
    
    Header.init().open('map');
    
    MapController.refresh();
    MapController.refreshVehicleList();
  };
  
  /**
   * teardown()
   *
   * Hide all of our panes and throw away any unnecessary resources.
   */
  MapController.teardown = function() {
    MapPane.popup(); // hide and 'save' popup because points are destroyed
    MapPane.close().hideCollection('vehicles');
    MapPane.hideCollection('trip');
    VehiclePane.close().showVehicles('').historyEnabled(false);
    TripHistoryPane.close();
    TripPlayerPane.close();
    Header.standard('');
    
    vehicles = null;
    lookup = null;
    selected_id = null;
    tripVehicle = null;
    trips = [];
    tripLookup = null;
    MapPane.collection('vehicles').removeAll();
  };
  
  /**
   * refresh()
   *
   * Load all vehicles from the server and populate them. This call loads actual
   * vehicle data (as opposed to a "hierarchy" html view).
   */
  MapController.refresh = function() {
    vehicles = lookup = null;
    
    loading(true);
    
    $.getJSON('/devices.json', function(json) {
      var idx, num, html;
      
      vehicles = json;
      
      for(idx = 0, num = vehicles.length, lookup = {}; idx < num; idx++) {
        lookup[vehicles[idx].id] = vehicles[idx];
      }
      
      showVehiclesOnMap(vehicles);
      
      loading(false);
    });
  };
  
  /**
   * refreshVehicleList()
   *
   * Load the hierarchy HTML from the server and display it in the vehicles pane.
   */
  MapController.refreshVehicleList = function() {
    loading(true);
    
    $.get('/devices', function(html) {
      VehiclePane.showVehicles(html);
      
      loading(false);
    });
  };
  
  /**
   * focus(vehicle)
   *
   * Pan the map to the given vehicle.
   *
   * focus()
   *
   * Pan the map to the clicked vehicle. Called as an event handler.
   */
  MapController.focus = function(o) {
    if (tripVehicle) {
      // Hovering is currently undefined while viewing trips
      return false;
    }
  
    var id;
    
    if (!o || (o && o.originalEvent)) {
      // If no arg, or arg is a jQuery event object, find the vehicle
      // associated with the clicked dom element.
      id = $(this).attr('id');

      // but not the group!
      if (id.indexOf('group') < 0)
      {
        id = id.substring(id.lastIndexOf('_') + 1);
        o = lookup[id];
      }
    }

    if (selected_id != null) {
      // hide currently shown popup
      VehiclePane.toggleActive(lookup[selected_id]);
      MapPane.popup(false);
    }

    if (o) {
      if (selected_id == o.id || o.poi == null) {
        // clicked on active item - just hide it.
        selected_id = null;
      } else {
        selected_id = o.id;
        showVehicleOnMap(o);
        showVehiclePopup(o);
        VehiclePane.toggleActive(o);
        MapPane.pan(o.poi);
      }
      
    } else {
      // can happen if a group gets focus
      selected_id = null;
    }
    
    return false;
  };
  
  /**
   * focusPoint()
   *
   * Called when a user clicks a point in the map pane. When called, this
   * function will have the MapQuest POI as its context.
   */
  MapController.focusPoint = function() {
    if (tripVehicle) {
      // Hovering is currently undefined while viewing trips
      return false;
    }
    
    var v = this.reference;
    
    MapController.focus(v);
  
    return false;
  };
  
  /**
   * hoverPoint(bool)
   *
   * Called when a user hovers over or out of a point in the map pane. When
   * called, this function will have the MapQuest POI as its context. The
   * bool argument will be true if the mouse is over the point, false otherwise.
   */
  MapController.hoverPoint = function(bool) {
    if (tripVehicle) {
      // Hovering is currently undefined while viewing trips
      return false;
    }
  
    var v = this.reference, html;
    
    if (selected_id == null) {
      if (bool) {
        showVehiclePopup(v);
      } else {
        MapPane.popup();
      }
    }
    
    return false;
  };
  
  /**
   * enterTripHistory()
   *
   * Enter trip history mode for the given vehicle. This function is called as
   * an event handler, so "this" will be the clicked Calendar link in the
   * vehicle pane. In trip history mode, the vehicle pane is hidden and the
   * user can scroll through the trips for the given vehicle.
   */
  MapController.enterTripHistory = function() {
    var id = $(this).closest('div.row').attr('id');
    id = id.substring(id.lastIndexOf('_') + 1);
    
    if (tripVehicle = lookup[id]) {
      TripHistoryPane.open();
      MapController.updateTripList();
      
      MapPane.slide(0);
      MapPane.hideCollection('vehicles');
      MapPane.showCollection('trip');
      VehiclePane.close();
      Header.open('history', {
        title: 'Trip History - ' + tripVehicle.name,
        back: MapController.exitTripHistory
      });
      
      loading(false);
    }
    
    return false;
  };
  
  /**
   * hoverTrip()
   *
   * Event handler.
   */
  MapController.hoverTrip = function() {
    var id = $(this).attr('id');
    id = id.substring(id.indexOf('_') + 1);
    
    if (tripLookup[id]) {
      TripHistoryPane.hover(this, tripLookup[id]);
    }
    
    return false;
  };
  
  /**
   * viewTrip()
   *
   * An event handler.
   */
  MapController.viewTrip = function() {
    var id = $(this).attr('id');
    id = id.substring(id.indexOf('_') + 1);
    
    loading(true);
    
    $.getJSON('/trips/' + id + '.json', function(json) {
      showTripOnMap(json);
      TripPlayerPane.trip(json).open();
      
      loading(false);
    });
    
    return false;
  };
  
  /**
   * tripProgress(index)
   *
   * Call when in Trip History mode to pan the map to the appropriate
   * point in the current trip, using the given index (0-N).
   */
  MapController.tripProgress = function(index) {
    // TODO: A few lines of minimal error checking wouldn't hurt
    MapPane.pan(MapPane.collection('trip').getAt(index));
  };
  
  /**
   * exitTripHistory()
   *
   * Hide any trips being displayed and all history-related panes, return
   * the user to the vehicle pane + map view.
   */
  MapController.exitTripHistory = function() {
    TripPlayerPane.close().trip();
    TripHistoryPane.close().trips();
    
    VehiclePane.open(function() {
      MapPane.slide(VehiclePane.width());
      MapPane.showCollection('vehicles');
      MapPane.collection('trip').removeAll();
      
      MapPane.bestFit(MapPane.collection('vehicles'));
    });
    
    Header.open('map');
    tripVehicle = null;
    trips = [];
    tripLookup = null;
    
    return false;
  };
  
  /**
   * updateTripList(date)
   *
   * Called as an event handler. Uses the just-picked date from the date
   * selector and the saved id of the vehicle that we are viewing trip history
   * for.
   *
   * If no date is passed, it uses whatever date is already in the date text
   * field.
   */
  MapController.updateTripList = function(date) {
    var idx, num, id = tripVehicle.id;
    
    if (!date) {
      date = $('#trip_history_date').val();
    }
    
    loading(true);
    
    $.getJSON('/devices/' + id + '/trips.json', {date: date}, function(json) {
      trips = json;
      
      for(idx = 0, num = trips.length, tripLookup = {}; idx < num; idx++) {
        tripLookup[trips[idx].id] = trips[idx];
      }
      
      TripHistoryPane.trips(trips);
      
      loading(false);
      
      TripHistoryPane.selectDefaultTrip();
    });
  
    return false;
  };
  
  /* Private Functions */
  
  function showVehiclesOnMap(vehicles) {
    var idx, num, v,
        collection = MapPane.collection('vehicles');
    
    for(idx = 0, num = vehicles.length; idx < num; idx++) {
      v = vehicles[idx];
      
      if (!v.poi && v.position) {
        v.poi = MapPane.addPoint(v.position.latitude, v.position.longitude, {
          icon: '/images/points/red.png',
          size: [11, 11],
          offset: [-6, -6],
          collection: collection,
          reference: v
        });
      }
    }
  }
  
  function showVehicleOnMap(vehicle) {
    if (!vehicle.poi && vehicle.position) {
      vehicle.poi = MapPane.addPoint(vehicle.position.latitude, vehicle.position.longitude, {
        icon: '/images/points/red.png',
        size: [11, 11],
        offset: [-6, -6],
        collection: 'vehicles',
        reference: vehicle
      });
    }
  }
  
  function showTripOnMap(trip) {
    var idx, num, leg, j, p,
        collection = MapPane.collection('trip');
    
    collection.removeAll();
    
    for(idx = 0, num = trip.legs.length; idx < num; idx++) {
      leg = trip.legs[idx];
      
      for(j = 0; j < leg.displayable_points.length; j++) {
        p = leg.displayable_points[j];
        
        if (!p.poi) {
          p.poi = MapPane.addPoint(p.latitude, p.longitude, {
            icon: '/images/points/red.png',
            size: [11, 11],
            offset: [-6, -6],
            collection: collection,
            reference: p
          });
        }
      }
    }
    
    MapPane.bestFit(collection);
  }
  
  function loading(bool) {
    Frame.loading(bool);
    Header.loading(bool);
  }
  
  /**
   * showVehiclePopup()
   *
   * Called to make a vehicle's popup visible
   */
  function showVehiclePopup(v) {
    if (v.poi) {
      html = '<h4>' + v.name + '</h4><p>' + v.position.time_of_day + '</p><p>' + v.position.occurred_at.substring(0, 10) + '</p>';
          
      MapPane.popup(v.poi, html);
    }
  }

  return MapController;
}(Fleet.MapController || {},
  Fleet.Frame.MapPane,
  Fleet.Frame.VehiclePane,
  Fleet.Frame.TripHistoryPane,
  Fleet.Frame.TripPlayerPane,
  Fleet.Frame.Header,
  Fleet.Frame,
  jQuery));
