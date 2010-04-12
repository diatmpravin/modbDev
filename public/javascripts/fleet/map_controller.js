/**
 * Fleet.MapController
 */
var Fleet = Fleet || {};
Fleet.MapController = (function(MapController, MapPane, VehiclePane, Header, Frame, $) {
  var vehicles = null,
      lookup = null,
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
    VehiclePane.init().open();
    
    Header.init().switch('map');
    
    MapController.refresh();
  };
  
  /**
   * teardown()
   *
   * Hide all of our panes and throw away any unnecessary resources.
   */
  MapController.teardown = function() {
    MapPane.close();
    VehiclePane.close();
    Header.standard('');
    
    vehicles = null;
    lookup = null;
    MapPane.collection('vehicles').removeAll();
  };
  
  /**
   * refresh()
   *
   * Load all vehicles from the server and populate them.
   */
  MapController.refresh = function() {
    vehicles = lookup = null;
    
    /*$.getJSON('/landmarks.json', function(json) {
      var idx, num, html;
      
      landmarks = json;
      
      for(idx = 0, num = landmarks.length, lookup = {}; idx < num; idx++) {
        lookup[landmarks[idx].id] = landmarks[idx];
      }
      
      LandmarkPane.showLandmarks(landmarks);
      showLandmarksOnMap(landmarks);
    });*/
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
      id = id.substring(id.lastIndexOf('_') + 1);
      
      o = lookup[id];
    }
    
    if (o) {
      showVehicleOnMap(o);
      MapPane.pan(o.poi);
    }
    
    return false;
  };
  
  /* Private Functions */
  
  function showVehiclesOnMap(vehicles) {
    var idx, num, v,
        collection = MapPane.collection('vehicles');
    
    for(idx = 0, num = vehicles.length; idx < num; idx++) {
      v = vehicles[idx];
      
      if (!v.poi) {
        v.poi = MapPane.addPoint(v.position.latitude, v.position.longitude, {
          collection: collection,
          reference: v
        });
      }
    }
  }
  
  function showVehicleOnMap(vehicle) {
    if (!vehicle.poi) {
      vehicle.poi = MapPane.addPoint(vehicle.position.latitude, vehicle.position.longitude, {
        collection: 'vehicles',
        reference: vehicle
      });
    }
  }
  
  function loading(bool) {
    Frame.loading(bool);
    Header.loading(bool);
  }
  
  return MapController;
}(Fleet.MapController || {},
  Fleet.Frame.MapPane,
  Fleet.Frame.VehiclePane,
  Fleet.Frame.Header,
  Fleet.Frame,
  jQuery));
