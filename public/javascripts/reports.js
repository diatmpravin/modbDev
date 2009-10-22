/**
 * Reports
 *
 * Constants and functions used on the Reports page.
 *
 * Remember: jQuery = q() or $q()!
 */
Reports = {
  init: function() {
    q('#report_range_type').change(function(event) {
      // Custom is 7
      if(event.target.value == 7) {
        q("#date_select").slideDown();
      } else {
        q("#date_select").slideUp();
      }
    });

    q('#select_all').live("click", function(event) {
      var checked = this.checked;

      q(this).parents("#device_select").find(":select").each(function() {
        this.checked = checked;
      });
    });

    q('#report_range_start,#report_range_end').datepicker({
      duration: 'fast',
      maxDate: new Date(MoshiTime.serverTime),
      constrainInput: true
    });
  }
};

/* Initializer */
jQuery(function() {
  Reports.init();
});
