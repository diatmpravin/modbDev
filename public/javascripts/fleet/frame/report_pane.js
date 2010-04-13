/**
 * Fleet.Frame.ReportPane
 *
 * Represents the report pane within our resizable frame.
 *
 */
//This needs to have sizes more like map pane than landmark pane.
var Fleet = Fleet || {};
Fleet.Frame = Fleet.Frame || {};
Fleet.Frame.ReportPane = (function(ReportPane, Fleet, $) {
  var pane,
      container,
      init = false;
  
  /**
   * init()
   *
   * Create and prepare the Report pane.
   */
  ReportPane.init = function() {
    if (init) {
      return ReportPane;
    }
    
    // Create the report pane
    $('#frame').append('<div id="report_pane"><div id="runReportForm" class="report_selection"></div></div>');
    
    // Store a permanent reference to the pane
    pane = $('#report_pane');
    
    container = $('#runReportForm')
   
    // switch report description when type is switched
    // moved to init pane because jQuery doesn't currently support live change for IE
    //$('#report_type').live('change', Fleet.ReportController.reportType);

    // show and hide custom date entry
    $('#report_range_type').live('click', function() {
      if ($(this).val() == 7) {
        $('#date_select').slideDown('fast');
      } else {
        $('#date_select').slideUp('fast');
      }
    });

    // Prevent normal submit of report form
    $('#' + container[0].id + ' input[type=submit]').live('click', Fleet.ReportController.createReport);

    init = true;
    return ReportPane;
  };
   
  /**
   * Prepare anything necessary for the report pane. If
   * provided, load up the pane first with the given HTML.
   */
  ReportPane.initPane = function(html) {
    if (typeof(html) != 'undefined') {
      $('#report_pane .report_selection').html(html);
    }

    $('#report_type').bind('change', Fleet.ReportController.reportType);

    // custom date entry pickers
    $('#report_range_start,#report_range_end').datepicker({
      duration: 'fast',
      maxDate: new Date(MoshiTime.serverTime),
      constrainInput: true
    });

    return $('#report_pane .report_selection');
  };
  
 
  /**
   * open()
   *
   * Open the report pane.
   */
  ReportPane.open = function() {
    pane.show();
    
    return ReportPane;
  };
  
  /**
   * close()
   *
   * Close the report pane.
   */
  ReportPane.close = function() {
    pane.hide();
    
    return ReportPane;
  };

  /**
  * Display the description for the selected report type.
  */
  ReportPane.showCurrentDescription = function() {
    $('#report_' + $('#report_type').val() + '_description')
      .show()
      .siblings().hide();
  };

  return ReportPane;
}(Fleet.Frame.ReportPane || {}, Fleet, jQuery));
