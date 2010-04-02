/**
 * Fleet.LandmarkController
 *
 * Landmark Controller!
 */
var Fleet = Fleet || {};
Fleet.LandmarkController = (function(LandmarkController, LandmarkPane, LandmarkEditPane, MapPane, $) {
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
    var id, landmark;

    id = $(this).attr('id');
    id = id.substring(id.lastIndexOf('_') + 1);
    
    if (landmark = lookup[id]) {
      showLandmarkOnMap(lookup[id]);
      MapPane.pan(lookup[id].poi);
    }
    
    MapPane.slide(0, function() {
      LandmarkPane.close(function() {
        LandmarkEditPane.open();
      });
    });
    
    return false;
  };
  
  /**
   * cancel()
   *
   * Transition back to the list view.
   */
  LandmarkController.cancel = function() {
    LandmarkEditPane.close();
    LandmarkPane.open(function() {
      MapPane.slide(LandmarkPane.width());
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
  };
  
  function showLandmarkOnMap(landmark) {
    if (!landmark.poi) {
      landmark.poi = MapPane.addPoint(landmark.latitude, landmark.longitude, {
        collection: 'landmarks',
        reference: landmark
      });
    }
  };
  
  return LandmarkController;
}(Fleet.LandmarkController || {}, Fleet.Frame.LandmarkPane, Fleet.Frame.LandmarkEditPane, Fleet.Frame.MapPane, jQuery));
