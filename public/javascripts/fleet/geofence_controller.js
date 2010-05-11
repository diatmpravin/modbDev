/**
 * Fleet.GeofenceController
 */
var Fleet = Fleet || {};
Fleet.GeofenceController = (function(GeofenceController, GeofencePane, GeofenceEditPane, MapPane, GroupPane, Header, Frame, $) {
  var confirmRemoveDialog,
      geofences = null,
      lookup = null,
      activeShape = null,
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
    activeShape = null;
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
      
      if (o.shape) {
        MapPane.bestFit(o.shape);
      }
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
      Header.edit('New Geofence',
        GeofenceController.save,
        GeofenceController.cancel
      );
      
      editGeofenceOnMap(null);
      
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
      
      // Make sure our geofence object is up to date, then show it on map
      geofence.coordinates = GeofenceEditPane.coordinates();
      editGeofenceOnMap(geofence);
      
      loading(false);
    }
    
    return false;
  };
  
  /**
   * save()
   *
   * Save the landmark currently being edited. This handler is used by both New
   * and Edit Landmark.
   */
  GeofenceController.save = function() {
    var g;
    
    loading(true);
    
    // Get the selected groups from the group pane into the form
    GeofenceEditPane.groups(GroupPane.selected());
    
    GeofenceEditPane.submit({
      dataType: 'json',
      success: function(json) {
        loading(false);
        
        if (json.status == 'success') {
          // If it's an update, get rid of the old geofence
          if (g = lookup[json.geofence.id]) {
            if (g.shape) {
              MapPane.removeShape(g.shape, 'geofences');
            }
            g.shape = null;
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
          if (lookup[id].shape) {
            MapPane.removeShape(lookup[id].shape, 'geofences');
            lookup[id].shape = null;
            lookup[id] = null;
          }
        } else {
          confirmRemoveDialog.errors(json.error).dialog('open');
        }
      }
    });
  
    return false;
  };
  
  /**
   * dragShape()
   *
   * Called by the MapPane.Geofence module whenever a user has finished
   * dragging a geofence around. We will update the edit form with the
   * new coordinates.
   */
  GeofenceController.dragShape = function() {
    if (activeShape) {
      GeofenceEditPane.coordinates(activeShape.getShapePoints());
    }
  
    return false;
  };
  
  /**
   * dragHandle(handle)
   *
   * Called by the MapPane.Geofence module whenever a user has finished
   * dragging a geofence handle around. We will update the shape and
   * then update the edit form with the new coordinates.
   */
  GeofenceController.dragHandle = function(handle) {
    alert(1);
  };
  
  /**
   * convertShape(newType)
   *
   * Called when the user switches the geofence type in the edit pane.
   */
  GeofenceController.convertShape = function(newType) {
    if (activeShape) {
      MQA.EventManager.clearListeners(activeShape, 'mousedown');
      MapPane.removeShape(activeShape, 'temp');
      
      activeShape = MapPane.addShape(newType, MapPane.Geofence.convertShapeCoordinates(activeShape, newType), {
        collection: 'temp'
      });
      MQA.EventManager.addListener(activeShape, 'mousedown', function(mqEvent) {
        MapPane.Geofence.dragShapeStart(activeShape, mqEvent);
      });
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
      geofence.shape = MapPane.addShape(geofence.geofence_type, geofence.coordinates, {
        collection: 'geofences',
        reference: geofence
      });
    }
  }
  
  function editGeofenceOnMap(geofence) {
    var idx, num;
    
    // Clear any existing stuff in the temp collection
    MapPane.collection('temp').removeAll();
    
    // Create the shape on the map
    if (geofence) {
      activeShape = MapPane.addShape(geofence.geofence_type, geofence.coordinates, {
        collection: 'temp'
      });
    } else {
      activeShape = MapPane.newShape({
        collection: 'temp'
      });
    }
    
    // Display the shape to be edited and hide any other geofences
    MapPane.showCollection('temp');
    MapPane.hideCollection('geofences');
    
    // Hook up the drag event for the shape itself
    MQA.EventManager.addListener(activeShape, 'mousedown', function(mqEvent) {
      MapPane.Geofence.dragShapeStart(activeShape, mqEvent);
    });
    
    // Create the resize handles for this shape
    activeShape.handles = MapPane.Geofence.handles(activeShape);
    for(idx = 0, num = activeShape.handles.length; idx < num; idx++) {
      MapPane.collection('temp').add(activeShape.handles[idx]);
      
      MQA.EventManager.addListener(activeShape.handles[idx], 'mousedown', MapPane.Geofence.dragHandleStart);
      MQA.EventManager.addListener(activeShape.handles[idx], 'mouseup', MapPane.Geofence.dragHandleEnd);
    }
  }
  
  function closeEditPanes() {
    var idx, num;
    
    MapPane.showCollection('geofences');
    MapPane.hideCollection('temp');
    MapPane.collection('temp').removeAll();
    
    MQA.EventManager.clearListeners(activeShape, 'mousedown');
    if (activeShape.handles) {
      for(idx = 0, num = activeShape.handles.length; idx < num; idx++) {
        MQA.EventManager.clearListeners(activeShape.handles[idx], 'mousedown');
        MQA.EventManager.clearListeners(activeShape.handles[idx], 'mouseup');
      }
    }
    activeShape.handles = null;
    activeShape = null;
    
    Header.open('geofences');
    GroupPane.close();
    GeofenceEditPane.close();
    GeofencePane.open(function() {
      MapPane.slide(GeofencePane.width());
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
