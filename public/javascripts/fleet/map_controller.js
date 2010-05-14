/**
 * Fleet.MapController
 */
var Fleet = Fleet || {};
Fleet.MapController = (function(MapController, MapPane, VehiclePane, TripPlayerPane, Header, Frame, $) {
  var vehicles = null,
      lookup = null,
      selected_id = null;
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
    
    Header.init().define('map',
      '<span class="title">Map View</span>');
    
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
    VehiclePane.init().open().selectEnabled(false);
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
    VehiclePane.close().showVehicles('');
    TripPlayerPane.close();
    Header.standard('');
    
    vehicles = null;
    lookup = null;
    selected_id = null;
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
    var v = this.reference, html;

    if (selected_id == null) {  
      if (bool) {
        showVehiclePopup(v);
      } else {
        MapPane.popup();
      }
    }
    
    
    /*if (bool) {
      $('#frame_header span.title').text('Hovering over vehicle id '+v.id);
    } else {
      $('#frame_header span.title').text('No more hover');
    }*/
    
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
  Fleet.Frame.TripPlayerPane,
  Fleet.Frame.Header,
  Fleet.Frame,
  jQuery));
