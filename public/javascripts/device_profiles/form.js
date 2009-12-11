/**
 * Device Profiles - Form
 */
if (typeof DeviceProfiles == 'undefined') {
  DeviceProfiles = {};
};
DeviceProfiles.Form = {
  init: function() {
    q('input.alert').live('click', function() {
      q(this).siblings('.extra').toggle(this.checked);
      
      DeviceProfiles.Form.initTimepickr(q(this).parent());
    });
    
    DeviceProfiles.Form.initTimepickr();
  }
  ,
  /**
   * Initialize a jQuery Timepickr for any inputs with a class of 'timepick'
   * in the given container. If no container is specified, initializes the
   * entire page.
   */
  initTimepickr: function(edit) {
    q(edit).find('input.timepick:visible').timepickr({
      convention: 12,
      format12: '{h:02.d}:{m:02.d} {z:s}',
      trigger: 'click'
    });
  }
};

/* Initializer */
jQuery(DeviceProfiles.Form.init);
