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
    
    $.getJSON('/reports', function(json) {
      ReportPane.initPane(json.html);
    });

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

  /**
   * Create a report via ajax, displaying it in a new window if successful.
   */
  //ReportPane.createReport = function() {
  //  var _form = $(this).closest('form');
  //  var _report = _form.data('report_form');
  //  
  //  // Copy the selection list into the form
  //  _form.find(_report.deviceField).val(_report.getSelection());
  //  _report.container.errors();
  //  
  //  _form.ajaxSubmit({
  //    dataType: 'json',
  //    beforeSubmit: function() { _form.find('.loading').show(); },
  //    complete: function() { _form.find('.loading').hide(); },
  //    success: function(json) {
  //      if (json.status == 'success') {
  //        window.open('/reports/' + json.report_id + '.html');
  //      } else {
  //        _report.container.errors(json.errors);
  //      }
  //    }
  //  });
  //  
  //  return false;
  //}
 
  return ReportController;
}(Fleet.ReportController || {}, Fleet.Frame.ReportPane, Fleet.Frame.VehiclePane, jQuery));
