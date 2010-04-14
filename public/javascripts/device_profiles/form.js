/**
 * Device Profile - Form
 */
if (typeof DeviceProfile == 'undefined') { DeviceProfile = {}; };

DeviceProfile.Form = {
  /**
   * Prepare any global page stuff.
   */
  init: function() {
    q('input.alert').live('click', function() {
      q(this).siblings('.extra').toggle(this.checked);
      
      // This "re-init" prevents an alignment bug
      //DeviceProfile.Form.initTimepickr(q(this).parent());
    });
  },
  
  /**
   * Init pane stuff.
   */
  initPane: function(element) {
    //DeviceProfile.Form.initTimepickr(element);
  },
  
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
jQuery(DeviceProfile.Form.init);
