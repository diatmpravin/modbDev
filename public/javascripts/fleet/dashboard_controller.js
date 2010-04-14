/**
 * Fleet.DashboardController
 */
var Fleet = Fleet || {};
Fleet.DashboardController = (function(DashboardController, DashboardPane, VehicleEditPane, GroupEditPane, Header, Frame, $) {
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
    
    // Define the big messy dashboard header
    Header.init().define('dashboard',
      '<span class="title">Dashboard</span>' +
      '<div class="dashboard_data">' +
      '<span class="first_start"><span>Start Time</span></span>' +
      '<span class="last_stop"><span>End Time</span></span>' +
      '<span class="operating_time"><span>Operating Time</span></span>' + 
      '<span class="miles_driven"><span>Miles Driven</span></span>' +
      '<span class="average_mpg"><span>Average MPG</span></span>' +
      '<span class="speed_events"><span>Speed Events</span></span>' +
      '<span class="geofence_events"><span>Geofence Events</span></span>' +
      '<span class="idle_events"><span>Idle Events</span></span>' +
      '<span class="aggressive_events"><span>Aggressive Events</span></span>' +
      '<span class="after_hours_events"><span>After Hours Events</span></span>' +
      '</div>');
    
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
    VehicleEditPane.init().close();
    GroupEditPane.init().close();
    
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
    
    $.getJSON('/dashboard.json', {range_type: 5}, function(json) {
      loading(false);
      
      DashboardPane.initPane(json.html, json.id);
    });
    
    /*
    
  // what range type?
  rt = q('#range_type').val();

  // get json for the report card tree
  q.getJSON('/report_card', { range_type: rt }, function(json) {
  */
    return DashboardController;
  };
  
  /**
   * edit()
   *
   * Show the edit form for the selected vehicle or group.
   */
  DashboardController.edit = function() {
    var row = $(this).closest('div.row');
    
    if (row.hasClass('group')) {
      loading(true);
      
      $.get($(this).attr('href'), function(html) {
        loading(false);
        
        GroupEditPane.initPane(html).open();
        DashboardPane.close();
        Header.edit('Edit Group', DashboardController.saveGroup, DashboardController.cancel);
      });
    } else {
      loading(true);
      
      $.get($(this).attr('href'), function(html) {
        loading(false);
        
        VehicleEditPane.initPane(html).open();
        DashboardPane.close();
        Header.edit('Edit Vehicle', DashboardController.saveVehicle, DashboardController.cancel);
      });
    }
    
    return false;
  };
  
  /**
   * saveGroup()
   *
   * Save the group currently being edited, closing the edit form and
   * returning to the dashboard if successful.
   */
  DashboardController.saveGroup = function() {
  
    return false;
  };
  
  /**
   * saveVehicle()
   *
   * Save the vehicle currently being edited, closing the edit form and
   * returning to the dashboard if successful.
   */
  DashboardController.saveVehicle = function() {
  
    return false;
  };
  
  /**
   * remove()
   *
   * Remove the selected vehicle or group.
   */
  DashboardController.remove = function() {
    alert(3);
    
    return false;
  };
  
  /**
   * cancel()
   *
   * Close the edit form for the current vehicle or group and return to the
   * dashboard view. Doesn't really matter which one the user is editing,
   * we'll close both forms just to be safe.
   */
  DashboardController.cancel = function() {
    DashboardPane.open(function() {
      GroupEditPane.close();
      VehicleEditPane.close();
    });
    
    Header.open('dashboard');
    
    return false;
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
  Fleet.Frame.VehicleEditPane,
  Fleet.Frame.GroupEditPane,
  Fleet.Frame.Header,
  Fleet.Frame,
  jQuery));
