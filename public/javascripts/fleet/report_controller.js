/**
 * Fleet.ReportController
 *
 * Report Controller
 */
var Fleet = Fleet || {};
Fleet.ReportController = (function(ReportController, ReportPane, VehiclePane, $) {
  var vehicles = null;
  //    lookup = null;
  
  /**
   * init()
   */
   
  
  /**
   * index()
   *
   * Prepare the vehicle list. This should always be called before any other
   * actions on the controller (most likely by the Frame).
   */
  ReportController.index = function() {
    VehiclePane.init().open();
    ReportPane.init().open();
    
    //ReportController.refresh();
  };
  
  //TODO: needs to get vehicles for the VehiclePane.
  /**
   * refresh()
   *
   * Load all landmarks from the server and populate them.
   */
  //ReportController.refresh = function() {
  //  landmarks = lookup = null;
  //  
  //  $.getJSON('/landmarks.json', function(json) {
  //    var idx, num, html;
  //    
  //    landmarks = json;
  //    
  //    for(idx = 0, num = landmarks.length, lookup = {}; idx < num; idx++) {
  //      lookup[landmarks[idx].id] = landmarks[idx];
  //    }
  //    
  //    LandmarkPane.showLandmarks(landmarks);
  //    showLandmarksOnMap(landmarks);
  //  });
  //};
  
  return ReportController;
}(Fleet.ReportController || {}, Fleet.Frame.ReportPane, Fleet.Frame.VehiclePane, jQuery));
