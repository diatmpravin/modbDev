/**
 * Fleet.ReportController
 *
 * Report Controller
 */
var Fleet = Fleet || {};
Fleet.ReportController = (function(ReportController, ReportPane, VehiclePane, Header, $) {
  var vehicles = null,
      report_form;
  
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
    VehiclePane.init().open();
    ReportPane.init().open();
    Header.init().switch('report', {title: 'Reports', create_report: ReportController.createReport});
  
    report_form = $('#runReportForm')
    $.getJSON('/reports', function(json) {
      ReportPane.initPane(json.html);
    });

    $.get('/devices', function(html) {
      VehiclePane.showVehicles(html);
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

  /**
   * Get the selected vehicle ids
   */
  ReportController.getSelection = function() {
    //TODO: get the values from the VehiclesPane
    //return [12,22,40]; 
    return VehiclePane.getSelectionsByClass('device');
  };
 
  return ReportController;
}(Fleet.ReportController || {}, 
  Fleet.Frame.ReportPane, 
  Fleet.Frame.VehiclePane, 
  Fleet.Frame.Header,
  jQuery));

