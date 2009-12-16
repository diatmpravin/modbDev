/**
 * Reports - Form
 *
 * Reports.Form is a component object instantiated by the page's main
 * javascript. See devices/index.js for example use.
 */
if (typeof Reports == 'undefined') {
  Reports = {};
}

/**
 * Create a new Reports.Form object. As currently written, should only be
 * instantiated once per page.
 *
 * Options:
 *   container - div or other HTML object containing the report form
 *   getSelection - a function that returns an array of device ids
 *   deviceField - a selector string defining which field will store device ids
 *
 * Example:
 *   new Reports.Form({
 *     container: q('#runReportForm'),
 *     getSelection: function() { return [1,2,3]; },
 *     deviceField: 'input[name=apply_ids]'
 *   });
 *
 */
Reports.Form = function(opts) {
  var self = this;
  
  this.container = q(opts.form || '#runReportForm');
  this.getSelection = opts.getSelection || function() { return []; };
  this.deviceField = opts.deviceField || 'input[name=apply_ids]';
  
  // Save a reference to this Reports.Form object in the form
  this.container.find('form').data('report_form', this);
  
  q('input.runReport').live('click', function() {
    q('.massApplyForm').slideUp('fast');
    self.container.slideDown('fast');
  });

  q('#report_type').live('click', function() {
    self.showCurrentDescription();
  });
  
  q('#report_range_type').live('click', function() {
    if (q(this).val() == 7) {
      q('#date_select').slideDown('fast');
    } else {
      q('#date_select').slideUp('fast');
    }
  });
  
  q('#report_range_start,#report_range_end').datepicker({
    duration: 'fast',
    maxDate: new Date(MoshiTime.serverTime),
    constrainInput: true
  });
  
  // Prevent normal submit of report form
  q('#' + this.container[0].id + ' input[type=submit]').live('click', this.createReport);
  
  this.showCurrentDescription();
};

Reports.Form.prototype = {
  /**
   * Display the description for the selected report type.
   */
  showCurrentDescription: function() {
    q('#report_' + q('#report_type').val() + '_description')
      .show()
      .siblings().hide();
  }
  ,
  /**
   * Create a report via ajax, displaying it in a new window if successful.
   */
  createReport: function() {
    var _form = q(this).closest('form');
    var _report = _form.data('report_form');
    
    // Copy the selection list into the form
    _form.find(_report.deviceField).val(_report.getSelection());
    _report.container.errors();
    
    _form.ajaxSubmit({
      dataType: 'json',
      beforeSubmit: function() { _form.find('.loading').show(); },
      complete: function() { _form.find('.loading').hide(); },
      success: function(json) {
        if (json.status == 'success') {
          window.open('/reports/' + json.report_id + '.html');
        } else {
          _report.container.errors(json.errors);
        }
      }
    });
    
    return false;
  }
};
