/**
 * Fleet.LandmarkController
 *
 * Landmark Controller!
 */
var Fleet = Fleet || {};
Fleet.LandmarkController = (function(LandmarkController, LandmarkPane, LandmarkEditPane, MapPane, GroupPane, Header, Frame, $) {
  var landmarks = null,
      lookup = null;
  
  /**
   * init()
   */
  
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
   * edit()
   *
   * Transition from index into editing a landmark.
   */
  LandmarkController.edit = function() {
    var id, landmark, landmarkHtml, groupHtml;

    id = $(this).attr('id');
    id = id.substring(id.lastIndexOf('_') + 1);
    
    if (landmark = lookup[id]) {
      showLandmarkOnMap(lookup[id]);
      MapPane.pan(lookup[id].poi);
    }
    
    Frame.loading(true); Header.loading(true);
    
    // We need to load two ajax requests, then move forward
    // when both are done.
    
    $.get('/landmarks/' + id + '/edit', function(html) {
      landmarkHtml = html;
      if (landmarkHtml) {
        ready();
      }
    });
    
    /*$.get('/landmarks/' + id + '/edit', function(html) {
      landmarkHtml = html;
      if (landmarkHtml && groupHtml) {
        ready();
      }
    });*/
    
    function ready() {
      LandmarkEditPane.open(landmarkHtml);
      LandmarkPane.close();
      GroupPane.open();
      Header.edit('Edit Landmark',
        LandmarkController.save,
        LandmarkController.cancel
      );
      
      Frame.loading(false); Header.loading(false);
      //MapPane.slide()
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
  
  return LandmarkController;
}(Fleet.LandmarkController || {},
  Fleet.Frame.LandmarkPane,
  Fleet.Frame.LandmarkEditPane,
  Fleet.Frame.MapPane,
  Fleet.Frame.GroupPane,
  Fleet.Frame.Header,
  Fleet.Frame,
  jQuery));
