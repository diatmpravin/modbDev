/**
 * Vehicles View
 *
 * Allows the user to see vehicles (display only). Can be included on
 * any page with a map view.
 *
 * Running this script on the main maps page will break it (so don't!).
 *
 * Note: it's up to the primary initializer in your page's script to call
 * VehiclesView.init(). This is to make sure it runs after MoshiMap, but
 * before anything on your page that might need it.
 */
VehiclesView = {
  vehicleCollection: new MQA.ShapeCollection(),
  vehicles: null,
  lookup: {},
  
  init: function(vehicleToggleField, labelToggleField) {
    VehiclesView.vehicleCollection.setName('vehicles');
    
    // If vehicles aren't already defined, load them with an ajax call.
    if (VehiclesView.vehicles != null) {
      VehiclesView.buildVehicles();
    } else {
      q.getJSON('/devices.json', function(json) {
        VehiclesView.vehicles = json;
        VehiclesView.buildVehicles();
      });
    }
    
    // Add them at the beginning and make sure they are displayed
    MoshiMap.moshiMap.map.addShapeCollection(VehiclesView.vehicleCollection);
    MoshiMap.moshiMap.bestFit();
    
    if (vehicleToggleField) {
      vehicleToggleField.click(VehiclesView.toggleVisibility)
                        .triggerHandler('click');
    }
    
    if (labelToggleField) {
      labelToggleField.click(VehiclesView.toggleLabels)
                      .triggerHandler('click');
    }
  }
  ,
  /**
   * Create a point in our vehicle collection for each vehicle.
   */
  buildVehicles: function() {
    for(var i = 0; i < VehiclesView.vehicles.length; i++) {
      var vehicle = VehiclesView.vehicles[i];
      
      if (vehicle.position != null) {
        var point = new MQA.Poi(new MQA.LatLng(vehicle.position.latitude, vehicle.position.longitude));
        
        point.setValue('icon', new MQA.Icon(
          // Budd doesn't want the "spinning" icon
          // vehicle.color.filename.match(/(.*?)\.png/)[1] + '_current.gif', 21, 21
          vehicle.color.filename, 11, 11
        ));
        point.setValue('iconOffset', new MQA.Point(-5, -5));
        point.setValue('shadow', new MQA.Icon('/images/blank.gif'));
        
        point.setValue('labelText', vehicle.name);
        point.setValue('labelClass', 'mapLabel');
        point.setValue('labelVisible', false);
        
        point.setValue('rolloverEnabled', true);
        point.setValue('infoTitleHTML', vehicle.name);
        
        if (!vehicle.connected) {
          point.setValue('infoContentHTML', 'As of ' + vehicle.position.time_of_day);
        }
        
        VehiclesView.vehicleCollection.add(point);
        
        VehiclesView.lookup[vehicle.id] = point;
      }
    }
  }
  ,
  /**
   * Toggle vehicle visibility based on the vehicle checkbox.
   */
  toggleVisibility: function() {
    if (q(this).attr('checked')) {
      MoshiMap.moshiMap.map.addShapeCollection(VehiclesView.vehicleCollection);
    } else {
      MoshiMap.moshiMap.map.removeShapeCollection('vehicles');
    }
  }
  ,
  /**
   * Toggle label visibility based on the labels checkbox.
   */
  toggleLabels: function() {
    var bool = q(this).attr('checked');
    
    for(var i = 0, s = VehiclesView.vehicleCollection.getSize(); i < s; i++) {
      VehiclesView.vehicleCollection.getAt(i).setValue('labelVisible', bool);
    }
  }
};

/* No initializer: call init() in your primary script. */
