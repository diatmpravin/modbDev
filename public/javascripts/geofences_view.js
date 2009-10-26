/**
 * Geofences View
 *
 * Allows the user to see geofences (display only). Can be included on
 * any page with a map view.
 *
 * Running this script on the main Geofences page will break it (so don't!).
 *
 * Note: it's up to the primary initializer in your page's script to call
 * GeofencesView.init(). This is to make sure it runs after MoshiMap, but
 * before anything on your page that might need it.
 */
GeofencesView = {
  ELLIPSE: 0,
  RECTANGLE: 1,
  POLYGON: 2,
  fences: null,
  vehicleListField: null,
  
  init: function(geofenceToggleField, vehicleListField) {
    // If fences aren't already defined, load them with an ajax call.
    if (GeofencesView.fences != null) {
      GeofencesView.buildGeofences();
    } else {
      q.getJSON('/geofences.json', function(json) {
        GeofencesView.fences = json;
        GeofencesView.buildGeofences();
      });
    }
    
    if (vehicleListField) {
      GeofencesView.vehicleListField = vehicleListField;
    }
    
    if (geofenceToggleField) {
      geofenceToggleField.click(GeofencesView.toggleVisibility)
                         .triggerHandler('click');
    }
  }
  ,
  /**
   * Toggle geofence visibility based on the geofence checkbox.
   *
   * If the vehicle list field is set, will restrict geofences shown to the
   * vehicle selected.
   */
  toggleVisibility: function() {
    var bool = q(this).attr('checked');
    var device = -1;
    
    if (GeofencesView.vehicleListField) {
      device = GeofencesView.vehicleListField.val() || '';
      device = device == '' ? -1 : parseInt(device);
    }

    for(var i = 0; i < GeofencesView.fences.length; i++) {
      var fence = GeofencesView.fences[i].geofence;
      
      fence.shape.setValue('visible',
        bool && (device < 0 || fence.device_ids.indexOf(device) >= 0)
      );
    }
  }
  ,
  /**
   * Build geofence shapes for each geofence and add them to the collection.
   */
  buildGeofences: function() {
    for(var i = 0; i < GeofencesView.fences.length; i++) {
      GeofencesView.shape(GeofencesView.fences[i].geofence);
      MoshiMap.moshiMap.geofenceCollection.add(GeofencesView.fences[i].geofence.shape);
    }
  }
  ,
  /**
   * Create and store a geofence shape for the given geofence.
   */
  shape: function(fence) {
    if (fence.geofence_type == GeofencesView.ELLIPSE) {
      fence.shape = new MQA.EllipseOverlay();
    } else if (fence.geofence_type == GeofencesView.RECTANGLE) {
      fence.shape = new MQA.RectangleOverlay();
    } else if (fence.geofence_type == GeofencesView.POLYGON) {
      fence.shape = new MQA.PolygonOverlay();
    }
    
    fence.points = new MQLatLngCollection();
    for(var i = 0; i < fence.coordinates.length; i++) {
      fence.points.add(new MQA.LatLng(fence.coordinates[i].latitude, fence.coordinates[i].longitude));
    }
    
    fence.shape.setShapePoints(fence.points);
    fence.shape.setValue('visible', false);
    GeofencesView.setFenceColor(fence, '#ff0000');
    
    return fence.shape;
  }
  ,
  setFenceColor: function(fence, color) {
    fence.shape.setColor(color);
    fence.shape.setColorAlpha(0.4);
    fence.shape.setFillColor(color);
    fence.shape.setFillColorAlpha(0.2);
  }
};

/* No initializer: call init() in your primary script. */
