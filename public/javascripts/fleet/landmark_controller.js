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
      init = false;
  
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
  
    init = true;
    return LandmarkController;
  };
  
  /**
   * index()
   *
   * Prepare the landmark list. This should always be called before any other
   * actions on the controller (most likely by the Frame).
   */
  LandmarkController.index = function() {
    MapPane.init().open().showCollection('landmarks');
    LandmarkPane.init().open();
    LandmarkEditPane.init().close();
    GroupPane.init().close();
    Header.init().standard('Landmarks');
    
    LandmarkController.refresh();
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
   * edit()
   *
   * Transition from index into editing a landmark.
   */
  LandmarkController.edit = function() {
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
      Header.edit('Edit Landmark',
        LandmarkController.save,
        LandmarkController.cancel
      );
      
      loading(false);
    }
    
    return false;
  };
  
  /**
   * save()
   *
   * Save the landmark currently being edited.
   */
  LandmarkController.save = function() {
    LandmarkEditPane.submit({
      dataType: 'json',
      success: function(json) {
        if (json.status == 'success') {
          closeEditPanes();
        } else {
          LandmarkEditPane.open(json.html);
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
          $('#landmark_' + id).hide('fast', function() {
            $(this).remove();
          });
          
          // Remove landmark from map
          if (lookup[id].poi) {
            MapPane.removePoint(lookup[id].poi);
            lookup[id].poi = null;
          }
        } else {
          confirmRemoveDialog.errors(json.error).dialog('open');
        }
      }
    });
  
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
  
  function closeEditPanes() {
    Header.standard('Landmarks');
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
