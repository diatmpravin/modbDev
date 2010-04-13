/**
 * Fleet.DashboardController
 */
var Fleet = Fleet || {};
Fleet.DashboardController = (function(DashboardController, DashboardPane, Header, Frame, $) {
  var vehicles = null,
      lookup = null,
      init = false;
  
  /* Dashboard Tab */
  DashboardController.tab = 'dashboard';
  
  /**
   * init()
   */
  DashboardController.init = function() {
    if (init) {
      return DashboardController;
    }
    
    Header.init().define('dashboard',
      '<span class="title">Dashboard</span>');
    
    init = true;
    return DashboardController;
  };
  
  /**
   * setup()
   *
   * Prepare all of our panes and setup the vehicle list view.
   */
  DashboardController.setup = function() {
    DashboardPane.init().open();
    
    Header.init().open('dashboard');
    
    DashboardController.refresh();
  };
  
  /**
   * teardown()
   *
   * Hide all of our panes and throw away any unnecessary resources.
   */
  DashboardController.teardown = function() {
    DashboardPane.close();
    Header.standard('');
    
    vehicles = null;
    lookup = null;
  };
  
  /**
   * refresh()
   *
   * Load all vehicles from the server and populate them. This call loads actual
   * vehicle data (as opposed to a "hierarchy" html view).
   */
  DashboardController.refresh = function() {
    loading(true);
    
    $.getJSON('/dashboard.json', function(json) {
      loading(false);
      
      DashboardPane.initPane(json.html, json.id);
    });
    
    /*
    
  // what range type?
  rt = q('#range_type').val();

  // get json for the report card tree
  q.getJSON('/report_card', { range_type: rt }, function(json) {
  */
  };
  
  /* Private Functions */
  /*
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
  }*/
  
  function loading(bool) {
    Frame.loading(bool);
    Header.loading(bool);
  }
  
  return DashboardController;
}(Fleet.DashboardController || {},
  Fleet.Frame.DashboardPane,
  Fleet.Frame.Header,
  Fleet.Frame,
  jQuery));
