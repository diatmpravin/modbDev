/**
 * Fleet.ReportController
 *
 * Report Controller
 */
var Fleet = Fleet || {};
Fleet.ReportController = (function(ReportController, ReportPane, VehiclePane, LandmarkPane, Header, $) {
  var report_form,
      vehiclesHtml = null,
      landmarkJson = null;
  
  /* Report Tab */
  ReportController.tab = 'reports';
  
  /**
   * init()
   */
  ReportController.init = function () {
  };
  
  /**
   * setup()
   * 
   * Prepare all of our panes and setup the report view.
   */
  ReportController.setup = function() {
    // set the header title and buttons
    Header.init().open('report', {title: 'Reports', create_report: ReportController.createReport});

    VehiclePane.init().open().selectEnabled(true);
    ReportPane.init().open();
    LandmarkPane.init().close();
    
    // store the report form location
    report_form = $('#runReportForm');
    
    // load up the report form content
    $.getJSON('/reports.json', function(json) {
      ReportPane.initPane(json.html);
    });

    // get the vehicles
    $.get('/devices', function(html) {
      vehiclesHtml = html;
      VehiclePane.showVehicles(vehiclesHtml);
    });

  };
  
  /**
   * teardown()
   *
   * Hide all of our panes and throw away any unnecessary resources.
   */
  ReportController.teardown = function() {
    report_form = null;
    vehiclesHtml = null;
    landmarkJson = null;

    VehiclePane.close().showVehicles('');
    LandmarkPane.close();
    ReportPane.close();
    Header.standard('');
  };
  
  /**
   * Create a report via ajax, displaying it in a new window if successful.
   */
  ReportController.createReport = function() {
    var _form = report_form.find('form');
    
    // Copy the selection list into the form
    _form.find('input[name=device_ids]').val(VehiclePane.getSelections());
    _form.find('input[name=landmark_ids]').val(LandmarkPane.getSelections());

    report_form.messageboxErrors();
    
    _form.ajaxSubmit({
      dataType: 'json',
      beforeSubmit: function() { Header.loading(true); },
      complete: function() { Header.loading(false); },
      success: function(json) {
        if (json.status == 'success') {
          window.open('/reports/' + json.report_id + '.html');
        } else {
          report_form.messageboxErrors(json.errors);
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
      if (landmarkJson === null) { 
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
      if (vehiclesHtml === null) {
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
      LandmarkPane.showLandmarks(landmarkJson, true).open(function() {
        VehiclePane.close();
        callback();
      });
    } else {
      LandmarkPane.showLandmarks(landmarkJson, true).open(function() {
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

  function loading(bool) {
    Fleet.Frame.loading(bool);
    Header.loading(bool);
  }

  /**
   * focus()
   */
  ReportController.focus = function() {
    // temporary hack - don't want it to call both
    if (VehiclePane.width() > 0) {
      VehiclePane.toggleActive.call(this);
    } else {
      LandmarkPane.toggleActive.call(this);
    }
  };
  
  return ReportController;
}(Fleet.ReportController || {}, 
  Fleet.Frame.ReportPane, 
  Fleet.Frame.VehiclePane, 
  Fleet.Frame.LandmarkPane,
  Fleet.Frame.Header,
  jQuery));

