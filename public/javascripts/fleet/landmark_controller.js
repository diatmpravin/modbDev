/**
 * Fleet.LandmarkController
 *
 * Landmark Controller!
 */
var Fleet = Fleet || {};
Fleet.LandmarkController = (function(LandmarkController, LandmarkPane, MapPane, $) {
  var landmarks = null,
      lookup = null;
  
  /**
   * init()
   */
   
  
  /**
   * index()
   *
   * Prepare the landmark "index".
   */
  LandmarkController.index = function() {
    LandmarkPane.init().open();
    MapPane.init().open();
    
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
      updateMap(landmarks);
    });
  };
  
  /**
   * Edit Handler
   */
  LandmarkController.edit = function() {
    var id, landmark;

    id = $(this).attr('id');
    id = id.substring(id.lastIndexOf('_') + 1);
    
    if (landmark = lookup[id]) {
      showLandmarkOnMap(lookup[id]);
      MapPane.pan(lookup[id].poi);
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
}(Fleet.LandmarkController || {}, Fleet.Frame.LandmarkPane, Fleet.Frame.MapPane, jQuery));
