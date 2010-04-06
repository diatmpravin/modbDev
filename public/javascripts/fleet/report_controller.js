/**
 * Fleet.ReportController
 *
 * Report Controller
 */
var Fleet = Fleet || {};
Fleet.ReportController = (function(ReportController, ReportPane, VehiclePane, $) {
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
    VehiclePane.init();
    ReportPane.init();
  
    report_form = $('#runReportForm')
    $.getJSON('/reports', function(json) {
      ReportPane.initPane(json.html);
    });

    VehiclePane.open();
    ReportPane.open();
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
      //TODO: show loading - beforeSubmit: function() { _form.find('.loading').show(); },
      //TOTO: end loading - complete: function() { _form.find('.loading').hide(); },
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
    return [12,22,40]; 
  };
 
  return ReportController;
}(Fleet.ReportController || {}, Fleet.Frame.ReportPane, Fleet.Frame.VehiclePane, jQuery));
