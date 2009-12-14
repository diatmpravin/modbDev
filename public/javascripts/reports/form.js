/**
 * Reports - Form
 */
if (typeof Reports == 'undefined') {
  Reports = {};
}

Reports.Form = {
  init: function() {
    q('input.runReport').live('click', function() {
      q('.massApplyForm').slideUp('fast');
      q('#runReportForm').slideDown('fast');
    });
  
    q('#report_type').live('click', function() {
      Reports.Form.showCurrentDescription();
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
    q('#runReportForm input[type=submit]').live('click', Reports.Form.createReport);
    
    Reports.Form.showCurrentDescription();
  }
  ,
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
    
    _form.ajaxSubmit({
      dataType: 'json',
      beforeSubmit: function() { _form.find('.loading').show(); },
      complete: function() { _form.find('.loading').hide(); },
      success: function(json) {
        if (json.status == 'success') {
          alert('Hooray!');
        } else {
          q('#runReportForm').html(json.html);
          Reports.Form.showCurrentDescription();
        }
      }
    });
    
    return false;
  }
};

jQuery(Reports.Form.init);
