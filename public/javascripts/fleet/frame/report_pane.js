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
    $('#frame').append('<div id="report_pane"><div id="runReportForm" class="report_selection">report pane goes here</div></div>');
    
    // Store a permanent reference to the pane
    pane = $('#report_pane');
    
    container = $('#runReportForm')

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
   
    // switch report description when type is switched
    $('#report_type').live('click', function() {
      ReportPane.showCurrentDescription();
    });

    // show and hide custom date entry
    $('#report_range_type').live('click', function() {
      if ($(this).val() == 7) {
        $('#date_select').slideDown('fast');
      } else {
        $('#date_select').slideUp('fast');
      }
    });

    // custom date entry pickers
    $('#report_range_start,#report_range_end').datepicker({
      duration: 'fast',
      maxDate: new Date(MoshiTime.serverTime),
      constrainInput: true
    });

    // Prevent normal submit of report form
    $('#' + container[0].id + ' input[type=submit]').live('click', ReportPane.createReport);

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

  /**
   * Create a report via ajax, displaying it in a new window if successful.
   */
  ReportPane.createReport = function() {
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
    return false;
  }

  return ReportPane;
}(Fleet.Frame.ReportPane || {}, Fleet, jQuery));
