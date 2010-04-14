/**
 * Fleet.LandmarkController
 *
 * Landmark Controller!
 */
var Fleet = Fleet || {};
Fleet.LandmarkController = (function(LandmarkController, LandmarkPane, LandmarkEditPane, MapPane, GroupPane, Header, Frame, $) {
  var confirmRemoveDialog,
      landmarks = null,
      lookup = null,
      activePoint = null,
      init = false;
  
  /* Landmark Tab */
  LandmarkController.tab = 'landmarks';
  
  /**
   * init()
   */
  LandmarkController.init = function() {
    if (init) {
      return LandmarkController;
    }
    
    // Our confirm remove dialog box
    confirmRemoveDialog = $('<div class="dialog" title="Remove Landmark?">Are you sure you want to remove this landmark?</div>').appendTo('body');
    confirmRemoveDialog.dialog({
      modal: true,
      autoOpen: false,
      resizable: false,
      width: 300,
      buttons: {
        'Remove': LandmarkController.confirmedRemove,
        'Cancel': function() { $(this).dialog('close'); }
      }
    });
    
    Header.init().define('landmarks',
      '<span class="buttons"><button type="button" class="newLandmark">Add New</button></span><span class="title">Landmarks</span>'
    );
    
    init = true;
    return LandmarkController;
  };
  
  /**
   * setup()
   *
   * Prepare all of our panes and setup the landmark list view.
   */
  LandmarkController.setup = function() {
    MapPane.init().open().showCollection('landmarks');
    LandmarkPane.init().open().editEnabled(true);
    LandmarkEditPane.init().close();
    GroupPane.init().close();
    Header.init().open('landmarks', {
      newLandmark: LandmarkController.newLandmark
    });
    
    LandmarkController.refresh();
  };
  
  /**
   * teardown()
   *
   * Hide all of our panes and throw away any unnecessary resources.
   */
  LandmarkController.teardown = function() {
    MapPane.close();
    LandmarkPane.close().editEnabled(false);
    LandmarkEditPane.close();
    GroupPane.close();
    Header.standard('');
    
    landmarks = null;
    lookup = null;
    activePoint = null;
    MapPane.collection('landmarks').removeAll();
  };
  
  /**
   * refresh()
   *
   * Load all landmarks from the server and populate them.
   */
  LandmarkController.refresh = function() {
    landmarks = lookup = null;
    
    $.getJSON('/landmarks.json', function(json) {
      var idx, num, html;
      
      landmarks = json;
      
      for(idx = 0, num = landmarks.length, lookup = {}; idx < num; idx++) {
        lookup[landmarks[idx].id] = landmarks[idx];
      }
      
      LandmarkPane.showLandmarks(landmarks);
      showLandmarksOnMap(landmarks);
    });
  };
  
  /**
   * focus(landmark)
   *
   * Pan the map to the given landmark.
   *
   * focus()
   *
   * Pan the map to the clicked landmark. Called as an event handler.
   */
  LandmarkController.focus = function(o) {
    var id;
    
    if (!o || (o && o.originalEvent)) {
      // If no arg, or arg is a jQuery event object, find the landmark
      // associated with the clicked dom element.
      
      id = $(this).attr('id');
      id = id.substring(id.lastIndexOf('_') + 1);
      
      o = lookup[id];
    }
    
    if (o) {
      showLandmarkOnMap(o);
      MapPane.pan(o.poi);
    }
    
    return false;
  };
  
  /**
   * newLandmark()
   *
   * Transition from index into creating a landmark.
   */
  LandmarkController.newLandmark = function() {
    var landmarkHtml, groupHtml;
    
    loading(true);
    
    // We need to load two ajax requests, then move forward
    // when both are done.
    var requests = 2;
    
    $.get('/landmarks/new', function(html) {
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
      
      LandmarkPane.close();
      LandmarkEditPane.initPane(landmarkHtml).open();
      GroupPane.showGroups(groupHtml).open();
      Header.edit('New Landmark',
        LandmarkController.save,
        LandmarkController.cancel
      );
      
      editLandmarkOnMap(null);
      LandmarkEditPane.location(MapPane.center());
      
      loading(false);
    }
    
    return false;
  };
  
  /**
   * edit()
   *
   * Transition from index into editing a landmark.
   */
  LandmarkController.edit = function(e) {
    var id, landmark, landmarkHtml, groupHtml;

    id = $(this).closest('li').attr('id');
    id = id.substring(id.lastIndexOf('_') + 1);
    
    if (landmark = lookup[id]) {
      LandmarkController.focus(landmark);
    }
    
    loading(true);
    
    // We need to load two ajax requests, then move forward
    // when both are done.
    var requests = 2;
    
    $.get('/landmarks/' + id + '/edit', function(html) {
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
      
      LandmarkPane.close();
      LandmarkEditPane.initPane(landmarkHtml).open();
      GroupPane.showGroups(groupHtml).open();
      GroupPane.select(LandmarkEditPane.groups());
      Header.edit('Edit Landmark',
        LandmarkController.save,
        LandmarkController.cancel
      );
      
      // Make sure our landmark object is up to date, then show it on map
      var l = LandmarkEditPane.location();
      landmark.latitude = l.latitude;
      landmark.longitude = l.longitude;
      editLandmarkOnMap(landmark);
      
      loading(false);
    }
    
    e.stopImmediatePropagation();
    return false;
  };
  
  /**
   * save()
   *
   * Save the landmark currently being edited. This handler is used by both New
   * and Edit Landmark.
   */
  LandmarkController.save = function() {
    var l;
    
    loading(true);
    
    // Get the selected groups from the group pane into the form
    LandmarkEditPane.groups(GroupPane.selected());
    
    LandmarkEditPane.submit({
      dataType: 'json',
      success: function(json) {
        loading(false);
        
        if (json.status == 'success') {
          // If it's an update, get rid of the old landmark
          if (l = lookup[json.landmark.id]) {
            if (l.poi) {
              MapPane.removePoint(l.poi, 'landmarks');
            }
            l.poi = null;
          }
          
          // Now create a new landmark
          lookup[json.landmark.id] = json.landmark;
          showLandmarkOnMap(json.landmark);
          LandmarkPane.showLandmark(json.landmark);
          
          closeEditPanes();
        } else {
          LandmarkEditPane.initPane(json.html);
        }
      }
    });
    
    return false;
  };
  
  /**
   * cancel()
   *
   * Cancel an in-progress Edit Landmark or Create Landmark state by going
   * back to the list view.
   */
  LandmarkController.cancel = function() {
    closeEditPanes();
    
    return false;
  };
  
  /**
   * remove()
   *
   * Display a confirmation dialog, asking if the user wants to remove the
   * clicked landmark.
   */
  LandmarkController.remove = function() {
    var id = $(this).closest('li').attr('id');
    id = id.substring(id.lastIndexOf('_') + 1);
  
    confirmRemoveDialog.data('id', id).errors().dialog('open');
    
    return false;
  };
   
  /**
   * confirmedRemove()
   *
   * Called after the user confirms the removal of a landmark.
   */
  LandmarkController.confirmedRemove = function() {
    var id = confirmRemoveDialog.data('id');
    
    confirmRemoveDialog.dialog('close');
    loading(true);
    
    $.ajax({
      url: '/landmarks/' + id,
      type: 'DELETE',
      dataType: 'json',
      success: function(json) {
        loading(false);
        if (json.status == 'success') {
          // Remove landmark from list
          $('#landmark_' + id).slideUp(400, function() {
            $(this).remove();
          });
          
          // Remove landmark from map
          if (lookup[id].poi) {
            MapPane.removePoint(lookup[id].poi, 'landmarks');
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
  LandmarkController.dragPoint = function(mqEvent) {
    if (activePoint) {
      LandmarkEditPane.location(activePoint.latLng);
    }
    
    return false;
  };
  
  /* Private Functions */
  
  function showLandmarksOnMap(landmarks) {
    var idx, num,
        collection = MapPane.collection('landmarks');
    
    for(idx = 0, num = landmarks.length; idx < num; idx++) {
      if (!landmarks[idx].poi) {
        landmarks[idx].poi = MapPane.addPoint(landmarks[idx].latitude, landmarks[idx].longitude, {
          collection: collection,
          reference: landmarks[idx]
        });
      }
    }
  }
  
  function showLandmarkOnMap(landmark) {
    if (!landmark.poi) {
      landmark.poi = MapPane.addPoint(landmark.latitude, landmark.longitude, {
        collection: 'landmarks',
        reference: landmark
      });
    }
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
    
    MQA.EventManager.addListener(activePoint, 'mouseup', LandmarkController.dragPoint);
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
  
  return LandmarkController;
}(Fleet.LandmarkController || {},
  Fleet.Frame.LandmarkPane,
  Fleet.Frame.LandmarkEditPane,
  Fleet.Frame.MapPane,
  Fleet.Frame.GroupPane,
  Fleet.Frame.Header,
  Fleet.Frame,
  jQuery));
