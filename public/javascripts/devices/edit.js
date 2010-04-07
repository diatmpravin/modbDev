/**
 * Management of the /devices/:id/edit page
 */
if(typeof Devices == "undefined") {
  Devices = {};
}

Devices.Edit = {
  init: function() {
    q('select.profile').change(Devices.Edit.setProfile);

    q('input.vinNumber').change(Devices.Edit.updateVIN).change();
  }
  ,
  /**
   * Show / hide the Lock VIN field if there's something in the vin text field
   */
  updateVIN: function() {
    if(q(this).val() == "") {
      q(".lockVIN").hide().find("input").attr('checked', false);
    } else {
      q(".lockVIN").show();
    }
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
        for(var f in json) {
          var field = q('.profileSettings input[type=checkbox][name$=\[' + f + '\]]');
          if (field.length > 0) {
            field.attr('checked', json.device_profile[f]);
          } else {
            field = q('.profileSettings input[name$=\[' + f + '\]],.profileSettings select[name$=\[' + f + '\]]');
            field.val(json[f]);
          }
        }
        
        q('.profileSettings').find('input[type=checkbox]').click();
        _this.siblings('.loading').hide();
      });
    }
  }
};

jQuery(Devices.Edit.init);
