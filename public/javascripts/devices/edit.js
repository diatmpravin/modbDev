/**
 * Management of the /devices/:id/edit page
 */
if(typeof Devices == "undefined") {
  Devices = {};
}

Devices.Edit = {
  init: function() {
    q('select.profile').change(Devices.Edit.setProfile);
  }
  ,
  /**
   * "Lock" the profile settings area and fill in the settings with an ajax
   * call. If the user has removed the profile, unlock the profile settings
   * area instead.
   */
  setProfile: function() {
    var _this = q(this);
    var profile = _this.val();
    
    if (profile == '') {
      q('.profileSettings').removeClass('profileLocked')
        .find('input,select').attr('disabled', false);
    } else {
      q('.profileSettings').addClass('profileLocked')
        .find('input,select').attr('disabled', true);
        
      _this.siblings('.loading').show();
      q.getJSON('/device_profiles/' + profile, function(json) {
        // This is more verbose than I want it to be, but I need to avoid
        // screwing up Rails' "checkbox+hidden-field" method of creating
        // checkboxes.
        for(var f in json.device_profile) {
          var field = q('.profileSettings input[type=checkbox][name$=\[' + f + '\]]');
          if (field.length > 0) {
            field.attr('checked', json.device_profile[f]);
          } else {
            field = q('.profileSettings input[name$=\[' + f + '\]],.profileSettings select[name$=\[' + f + '\]]');
            field.val(json.device_profile[f]);
          }
        }
        
        q('.profileSettings').find('input[type=checkbox]').click();
        _this.siblings('.loading').hide();
      });
    }
  }
};

jQuery(Devices.Edit.init);
