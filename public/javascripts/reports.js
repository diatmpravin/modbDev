/**
 * Reports
 *
 * Constants and functions used on the Reports page.
 *
 * Remember: jQuery = q() or $q()!
 */
Reports = {
  init: function() {
    q('a.runReport').click(Reports.run);
    q('a.openSettings').click(Reports.openSettings);
    
    q('#report_start_date,#report_end_date').datepicker({
      duration: 'fast',
      maxDate: new Date(MoshiTime.serverTime),
      constrainInput: true
    });
  }
  ,
  run: function() {
    q(this).closest('form').submit();
    return false;
  }
  ,
  openSettings: function() {
    q(this).closest('div').hide('fast').siblings().show('fast');
    return false;
  }
};

/* Initializer */
jQuery(function() {
  Reports.init();
});