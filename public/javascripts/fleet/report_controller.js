/**
 * Fleet.ReportController
 *
 * Report Controller
 */
var Fleet = Fleet || {};
Fleet.ReportController = (function(ReportController, ReportPane, VehiclePane, LandmarkPane, Header, $) {
  var report_form,
      vehicleHtml = null,
      landmarkJson = null;
  
  /**
   * init()
   */
  ReportController.init = function () {
  };
   
  
  /**
   * index()
   *
   * Prepare the vehicle list. This should always be called before any other
   * actions on the controller (most likely by the Frame).
   */
  ReportController.index = function() {
    // set the header title and buttons
    Header.init().switch('report', {title: 'Reports', create_report: ReportController.createReport});
    VehiclePane.init().open();
    ReportPane.init().open();
    LandmarkPane.init().close();
  
    // store the report form location
    report_form = $('#runReportForm')

    // load up the report form content
    $.getJSON('/reports', function(json) {
      ReportPane.initPane(json.html);
    });

    // get the vehicles
    $.get('/devices', function(html) {
      vehiclesHtml = html
      VehiclePane.showVehicles(vehiclesHtml);
    });

    //ReportController.refresh();
  };
  
  /**
   * Create a report via ajax, displaying it in a new window if successful.
   */
  ReportController.createReport = function() {
    var _form = report_form.find('form');
    
    // Copy the device selection list into the form
    _form.find('input[name=device_ids]').val(ReportController.getSelection());
    report_form.errors();
    
    _form.ajaxSubmit({
      dataType: 'json',
      beforeSubmit: function() { Header.loading(true); },
      complete: function() { Header.loading(false); },
      success: function(json) {
        if (json.status == 'success') {
          window.open('/reports/' + json.report_id + '.html');
        } else {
          report_form.errors(json.errors);
        }
      }
    });
    
    return false;
  };

  ReportController.reportType = function () {
    // update description of report
    ReportPane.showCurrentDescription();

    //TODO: set check behavior of appropriate selection pane. (multi or single)

    //right now, Landmark Summary (5) is the only report that doesn't use devices
    if ($(this).val() == '5') {
      if (landmarkJson == null) { 
        loading(true);

        // get the landmarks
        $.getJSON('/landmarks.json', function(json) {
          landmarkJson = json;
          
          // display the landmark pane
          ReportController.landmarks(function() {
            loading(false);
          });
        });
      } else {
        ReportController.landmarks();
      }
    } else {
      if (vehiclesHtml == null) {
        loading(true);

        // get the vehicles - prob. not necessary at this point
        $.get('/devices', function(html) {
          vehiclesHtml = html;

          ReportController.vehicles(function() {
            loading(false);
          });
        });
      } else if (VehiclePane.width() == 0) {
        ReportController.vehicles();
      }
    }
  };

  /**
   * Show the landmarks pane and if supplied, call a the callback
   * landmarks()
   * landmarks(callback)
   */
  ReportController.landmarks = function(callback) {
    if($.isFunction(callback)) {
      LandmarkPane.showLandmarks(landmarkJson).open(function() {
        $('#landmark_pane a.hover-only').addClass('hover-none').removeClass('hover-only');
        VehiclePane.close();
        callback();
      });
    } else {
      LandmarkPane.showLandmarks(landmarkJson).open(function() {
        $('#landmark_pane a.hover-only').addClass('hover-none').removeClass('hover-only');
        VehiclePane.close();
      });
    }
  };

  /**
   * Show the vehicles pane and if supplied, call a the callback
   * vehicles()
   * vehicles(callback)
   */
  ReportController.vehicles = function(callback) {
    if ($.isFunction(callback)) {
      VehiclePane.showVehicles(vehiclesHtml).open(function() {
        LandmarkPane.close();
        callback();
      });
    } else {
      VehiclePane.showVehicles(vehiclesHtml).open(function() {
        LandmarkPane.close();
      });
    }
  };

  /**
   * Get the selected vehicle ids
   */
  ReportController.getSelection = function() {
    //TODO: get the values from the VehiclesPane
    //return [12,22,40]; 
    return VehiclePane.getSelectionsByClass('device');
  };
 
  function loading(bool) {
    Fleet.Frame.loading(bool);
    Header.loading(bool);
  }

  return ReportController;
}(Fleet.ReportController || {}, 
  Fleet.Frame.ReportPane, 
  Fleet.Frame.VehiclePane, 
  Fleet.Frame.LandmarkPane,
  Fleet.Frame.Header,
  jQuery));

