/**
 * Fleet.GeofenceController
 */
var Fleet = Fleet || {};
Fleet.GeofenceController = (function(GeofenceController, GeofencePane, GeofenceEditPane, MapPane, GroupPane, Header, Frame, $) {
  var confirmRemoveDialog,
      geofences = null,
      lookup = null,
      activePoint = null,
      init = false;
  
  /* Geofence Tab */
  GeofenceController.tab = 'geofences';
  
  /**
   * init()
   */
  GeofenceController.init = function() {
    if (init) {
      return GeofenceController;
    }
    
    // Our confirm remove dialog box
    confirmRemoveDialog = $('<div class="dialog" title="Remove Geofence?">Are you sure you want to remove this geofence?</div>').appendTo('body');
    confirmRemoveDialog.dialog({
      modal: true,
      autoOpen: false,
      resizable: false,
      width: 300,
      buttons: {
        'Remove': GeofenceController.confirmedRemove,
        'Cancel': function() { $(this).dialog('close'); }
      }
    });
    
    Header.init().define('geofences',
      '<span class="buttons"><button type="button" class="newGeofence">Add New</button></span><span class="title">Geofences</span>'
    );
    
    init = true;
    return GeofenceController;
  };
  
  /**
   * setup()
   *
   * Prepare all of our panes and setup the geofence list view.
   */
  GeofenceController.setup = function() {
    MapPane.init().open().showCollection('geofences');
    GeofencePane.init().open().editEnabled(true);
    GeofenceEditPane.init().close();
    GroupPane.init().close();
    Header.init().open('geofences', {
      newGeofence: GeofenceController.newGeofence
    });
    
    GeofenceController.refresh();
  };
  
  /**
   * teardown()
   *
   * Hide all of our panes and throw away any unnecessary resources.
   */
  GeofenceController.teardown = function() {
    MapPane.close();
    GeofencePane.close().editEnabled(false);
    GeofenceEditPane.close();
    GroupPane.close().showGroups('');
    Header.standard('');
    
    geofences = null;
    lookup = null;
    activePoint = null;
    MapPane.collection('geofences').removeAll();
  };
  
  /**
   * refresh()
   *
   * Load all geofences from the server and populate them.
   */
  GeofenceController.refresh = function() {
    geofences = lookup = null;
    
    $.getJSON('/geofences.json', function(json) {
      var idx, num, html;
      
      geofences = json;
      
      for(idx = 0, num = geofences.length, lookup = {}; idx < num; idx++) {
        lookup[geofences[idx].id] = geofences[idx];
      }
      
      GeofencePane.showGeofences(geofences);
      showGeofencesOnMap(geofences);
    });
  };
  
  /**
   * focus(geofence)
   *
   * Pan the map to the given geofence.
   *
   * focus()
   *
   * Pan the map to the clicked geofence. Called as an event handler.
   */
  GeofenceController.focus = function(o) {
    var id;
    
    if (!o || (o && o.originalEvent)) {
      // If no arg, or arg is a jQuery event object, find the geofence
      // associated with the clicked dom element.
      
      id = $(this).attr('id');
      id = id.substring(id.lastIndexOf('_') + 1);
      
      o = lookup[id];
    }
    
    if (o) {
      showGeofenceOnMap(o);
      MapPane.pan(o.poi);
    }
    
    return false;
  };
  
  /**
   * focusPoint()
   *
   * Called when a user clicks a point in the map pane. When called, this
   * function will have the MapQuest POI as its context.
   */
  GeofenceController.focusPoint = function() {
    //var v = this.reference;
  
    return false;
  };
  
  /**
   * hoverPoint(bool)
   *
   * Called when a user hovers over or out of a point in the map pane. When
   * called, this function will have the MapQuest POI as its context. The
   * bool argument will be true if the mouse is over the point, false otherwise.
   */
  GeofenceController.hoverPoint = function(bool) {
    //var v = this.reference;
    
    return false;
  };
  
  /**
   * newGeofence()
   *
   * Transition from index into creating a geofence.
   */
  GeofenceController.newGeofence = function() {
    var geofenceHtml, groupHtml;
    
    loading(true);
    
    // We need to load two ajax requests, then move forward
    // when both are done.
    var requests = 2;
    
    $.get('/geofences/new', function(html) {
      landmarkHtml = html;
      
      ready();
    });
    
    // Strange "get json.html" because of Legacy Group page (for now)
    $.getJSON('/groups.json', function(json) {
      groupHtml = json.html;
      
      ready();
    });
    
    function ready() {
      requests -= 1;
      
      if (requests > 0) {
        // Don't move forward until both requests are complete
        return;
      }
      
      GeofencePane.close();
      GeofenceEditPane.initPane(geofenceHtml).open();
      GroupPane.showGroups(groupHtml).open();
      Header.edit('New Geofence',
        GeofenceController.save,
        GeofenceController.cancel
      );
      
      editGeofenceOnMap(null);
      GeofenceEditPane.location(MapPane.center());
      
      loading(false);
    }
    
    return false;
  };
  
  /**
   * edit()
   *
   * Transition from index into editing a geofence.
   */
  GeofenceController.edit = function(e) {
    var id, geofence, geofenceHtml, groupHtml;

    id = $(this).closest('li').attr('id');
    id = id.substring(id.lastIndexOf('_') + 1);
    
    if (geofence = lookup[id]) {
      GeofenceController.focus(geofence);
    }
    
    loading(true);
    
    // We need to load two ajax requests, then move forward
    // when both are done.
    var requests = 2;
    
    $.get('/geofences/' + id + '/edit', function(html) {
      geofenceHtml = html;
      
      ready();
    });
    
    // Strange "get json.html" because of Legacy Group page (for now)
    $.getJSON('/groups.json', function(json) {
      groupHtml = json.html;
      
      ready();
    });
    
    function ready() {
      requests -= 1;
      
      if (requests > 0) {
        // Don't move forward until both requests are complete
        return;
      }
      
      GeofencePane.close();
      GeofenceEditPane.initPane(geofenceHtml).open();
      GroupPane.showGroups(groupHtml).open();
      GroupPane.select(GeofenceEditPane.groups());
      Header.edit('Edit Geofence',
        GeofenceController.save,
        GeofenceController.cancel
      );
      
      // Make sure our landmark object is up to date, then show it on map
      var l = GeofenceEditPane.location();
      geofence.latitude = l.latitude;
      geofence.longitude = l.longitude;
      editGeofenceOnMap(geofence);
      
      loading(false);
    }
    
    //e.stopImmediatePropagation();
    return false;
  };
  
  /**
   * save()
   *
   * Save the landmark currently being edited. This handler is used by both New
   * and Edit Landmark.
   */
  GeofenceController.save = function() {
    var l;
    
    loading(true);
    
    // Get the selected groups from the group pane into the form
    GeofenceEditPane.groups(GroupPane.selected());
    
    GeofenceEditPane.submit({
      dataType: 'json',
      success: function(json) {
        loading(false);
        
        if (json.status == 'success') {
          // If it's an update, get rid of the old geofence
          if (l = lookup[json.geofence.id]) {
            if (l.poi) {
              MapPane.removePoint(l.poi, 'geofences');
            }
            l.poi = null;
          }
          
          // Now create a new geofence
          lookup[json.geofence.id] = json.geofence;
          showGeofenceOnMap(json.geofence);
          GeofencePane.showGeofence(json.geofence);
          
          closeEditPanes();
        } else {
          GeofenceEditPane.initPane(json.html);
        }
      }
    });
    
    return false;
  };
  
  /**
   * cancel()
   *
   * Cancel an in-progress Edit Geofence or Create Geofence state by going
   * back to the list view.
   */
  GeofenceController.cancel = function() {
    closeEditPanes();
    
    return false;
  };
  
  /**
   * remove()
   *
   * Display a confirmation dialog, asking if the user wants to remove the
   * clicked geofence.
   */
  GeofenceController.remove = function() {
    var id = $(this).closest('li').attr('id');
    id = id.substring(id.lastIndexOf('_') + 1);
  
    confirmRemoveDialog.data('id', id).errors().dialog('open');
    
    return false;
  };
   
  /**
   * confirmedRemove()
   *
   * Called after the user confirms the removal of a geofence.
   */
  GeofenceController.confirmedRemove = function() {
    var id = confirmRemoveDialog.data('id');
    
    confirmRemoveDialog.dialog('close');
    loading(true);
    
    $.ajax({
      url: '/geofences/' + id,
      type: 'DELETE',
      dataType: 'json',
      success: function(json) {
        loading(false);
        if (json.status == 'success') {
          // Remove geofence from list
          $('#geofence_' + id).slideUp(400, function() {
            $(this).remove();
          });
          
          // Remove geofence from map
          if (lookup[id].poi) {
            MapPane.removePoint(lookup[id].poi, 'geofences');
            lookup[id].poi = null;
          }
        } else {
          confirmRemoveDialog.errors(json.error).dialog('open');
        }
      }
    });
  
    return false;
  };
  
  /**
   * dragPoint(mqEvent)
   *
   * Called from MapQuest's Event Manager whenever a user drags a point on the
   * map. We will update the edit form with the new lat/long.
   */
  GeofenceController.dragPoint = function(mqEvent) {
    if (activePoint) {
      GeofenceEditPane.location(activePoint.latLng);
    }
    
    return false;
  };
  
  /* Private Functions */
  
  function showGeofencesOnMap(geofences) {
    var idx, num,
        collection = MapPane.collection('geofences');
    
    for(idx = 0, num = geofences.length; idx < num; idx++) {
      showGeofenceOnMap(geofences[idx]);
    }
  }
  
  function showGeofenceOnMap(geofence) {
    if (!geofence.shape) {
      geofence.shape = null;
    }
    
    /*if (!geofence.shape) {
      geofence.shape = MapPane.addShape(geofence.coordinates, {
        collection: 'geofences',
        reference: geofence,
      });*/
      
      /*landmark.poi = MapPane.addPoint(landmark.latitude, landmark.longitude, {
        icon: '/images/landmark.png',
        size: [16, 16],
        offset: [-10, -15],
        collection: 'landmarks',
        reference: landmark
      });*/
    //}
  }
  
  function editLandmarkOnMap(landmark) {
    MapPane.collection('temp').removeAll();
    
    if (landmark) {
      activePoint = MapPane.addPoint(landmark.latitude, landmark.longitude, {
        collection: 'temp',
        reference: landmark
      });
    } else {
      var c = MapPane.center();
      activePoint = MapPane.addPoint(c.lat, c.lng, {
        collection: 'temp'
      });
    }
    
    MQA.EventManager.addListener(activePoint, 'mouseup', GeofenceController.dragPoint);
    activePoint.setValue('draggable', true);
    
    MapPane.showCollection('temp');
    MapPane.hideCollection('landmarks');
  }
  
  function closeEditPanes() {
    MapPane.showCollection('landmarks');
    MapPane.hideCollection('temp');
    MapPane.collection('temp').removeAll();
    activePoint = null;
    
    Header.open('landmarks');
    GroupPane.close();
    LandmarkEditPane.close();
    LandmarkPane.open(function() {
      MapPane.slide(LandmarkPane.width());
    });
  }
  
  function loading(bool) {
    Frame.loading(bool);
    Header.loading(bool);
  }
  
  return GeofenceController;
}(Fleet.GeofenceController || {},
  Fleet.Frame.GeofencePane,
  Fleet.Frame.GeofenceEditPane,
  Fleet.Frame.MapPane,
  Fleet.Frame.GroupPane,
  Fleet.Frame.Header,
  Fleet.Frame,
  jQuery));
