/**
 * Devices
 *
 * Constants and functions used on the Device Settings page.
 */
Devices = {
  init: function() {
    q('input.addVehicle').live('click', Devices.newDevice);
    
    q('a.delete').live('click', function() {
      q('#removeDevice').find('form').attr('action', this.href).end()
                        .dialog('open');
      return false;
    });
    
    q('#devices_all').attr('checked', false).click(function() {
      q('input[name=devices]').attr('checked', this.checked);
    });
    q('table input[name=devices]').attr('checked', false).click(function() {
      q('#devices_all').attr('checked', false);
    });
    
    q('#mass_apply').val('').change(Devices.openMassApplyForm);
    q('.massApplyForm input.cancel').click(function() {
      q(this).closest('div').slideUp('fast');
    });
    q('.massApplyForm form').submit(function() {
      // When a mass apply form is submitted, copy the devices list into the form
      q(this).find('input[name=devices]').val(q('table input[name=devices]').fieldValue().join(','));
      return true;
    });
    
    q('select.profile').change(Devices.setProfile);
    
    q("#removeDevice").dialog({
      title: 'Remove Vehicle',
      modal: true,
      autoOpen: false,
      resizable: false,
      width: 450,
      buttons: {
        'Yes, remove this vehicle': Devices.destroy,
        'No, do not remove': function() { q(this).dialog('close'); }
      }
    });

    q("#addDevice").dialog({
      title: 'Add Vehicle',
      modal: true,
      autoOpen: false,
      resizable: false,
      width: 450,
      buttons: {
        'Add this Vehicle': Devices.create,
        'Cancel': function() { q(this).dialog('close').clearRailsForm(); }
      }
    });
  }
  ,
  newDevice: function() {
    q("#addDevice").dialog("open");
    
    return false;
  }
  ,
  create: function() {
    var _this = q(this);

    if(_this.data("running")) {
      return false; 
    }

    _this.data("running", true);
    
    _this.find('form').ajaxSubmit({
      dataType: 'json',
      beforeSubmit: function() { _this.dialogLoader().show(); },
      complete: function() { _this.dialogLoader().hide(); },
      success: function(json) {
        if (json.status == 'success') {
          location.reload();
        } else {
          _this.data("running", false); 
          _this.errors(json.error);
        }
      }
    });
    
    return false;
  }
  ,
  cancelNew: function() {
    var _new = q('#new');
    
    _new.hide('normal', function() {
      q.get('/devices/new', function(html) {
        _new.html(html);
        AlertRecipients.prepare(_new);
      });
    });
    q('a.addVehicle').parent().show('normal').siblings().not('#new').show();
    
    return false;
  }
  ,
  edit: function() {
    var _this = q(this);
    var _view = _this.parents('div.view');
    var _edit = _view.siblings('div.edit');
    
    _view.hide('normal').closest('div.device').siblings().hide();
    _edit.show('normal', function() {
      Devices.initTimepickr(_edit);
    });
    
    return false;
  }
  ,
  destroy: function() {
    var _this = q(this);
    
    _this.dialogLoader().show();
    _this.find('form').submit();
    
    return false;
  }
  ,
  openMassApplyForm: function() {
    var _this = q(this);
    if (_this.val() == '') {
      return;
    }
    
    var val = _this.val();
    _this.val('');
    
    switch(val) {
      case 'profile':
        q('.massApplyForm').slideUp('fast');
        q('#massApplyProfileForm').slideDown('fast');
        break;
      case 'add_group':
        q('.massApplyForm').slideUp('fast');
        q('#addToGroupForm').slideDown('fast');
        break;
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

/* Initializer */
jQuery(function() {
  Devices.init();
});
