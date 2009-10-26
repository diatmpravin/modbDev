/**
 * Landmarks View
 *
 * Allows the user to see landmarks (display only). Can be included on
 * any page with a map view.
 *
 * Running this script on the main Landmarks page will break it (so don't!).
 *
 * Note: it's up to the primary initializer in your page's script to call
 * LandmarksView.init(). This is to make sure it runs after MoshiMap, but
 * before anything on your page that might need it.
 */
LandmarksView = {
  landmarkCollection: new MQA.ShapeCollection(),
  landmarks: null,
  
  init: function(landmarkToggleField) {
    LandmarksView.landmarkCollection.setName('landmarks');
    
    // If landmarks aren't already defined, load them with an ajax call.
    if (LandmarksView.landmarks != null) {
      LandmarksView.buildLandmarks();
    } else {
      q.getJSON('/landmarks.json', function(json) {
        LandmarksView.landmarks = json;
        LandmarksView.buildLandmarks();
      });
    }
    
    if (landmarkToggleField) {
      landmarkToggleField.click(LandmarksView.toggleVisibility)
                         .triggerHandler('click');
    }
  }
  ,
  /**
   * Create a point in our landmark collection for each landmark.
   */
  buildLandmarks: function() {
    for(var i = 0; i < LandmarksView.landmarks.length; i++) {
      var landmark = LandmarksView.landmarks[i].landmark;
      
      var point = new MQA.Poi(new MQA.LatLng(landmark.latitude, landmark.longitude));
      point.setValue('icon', new MQA.Icon('/images/landmark.png', 24, 24));
      point.setValue('iconOffset', new MQA.Point(-12, -21));
      point.setValue('shadow', new MQA.Icon('/images/blank.gif'));
      point.setValue('rolloverEnabled', true);
      point.setValue('infoTitleHTML', landmark.name);
      
      LandmarksView.landmarkCollection.add(point);
    }
  }
  ,
  /**
   * Toggle landmark visibility based on the landmark checkbox.
   */
  toggleVisibility: function() {
    if (q('#show_landmarks').attr('checked')) {
      MoshiMap.moshiMap.map.addShapeCollection(LandmarksView.landmarkCollection);
    } else {
      MoshiMap.moshiMap.map.removeShapeCollection('landmarks');
    }
  }
};

/* No initializer: call init() in your primary script. */
