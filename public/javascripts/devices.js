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
    q('input[name=devices]').attr('checked', false).click(function() {
      q('#devices_all').attr('checked', false);
    });
    
    q('#mass_apply').val('').change(Devices.openMassApplyForm);
    q('.massApplyForm input.cancel').click(function() {
      q(this).closest('div').hide('fast');
    });
    
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
    
    /* editing alert settings */
    q('.alertInfo input[type=checkbox]').live('click', function() {
      q(this).siblings('.extra').toggle(this.checked);
      
      Devices.initTimepickr(q(this).parent());
    });
    
    Devices.initTimepickr(q('.alertInfo'));
  }
  ,
  initTimepickr: function(edit) {
    edit.find('input.timepick:visible').timepickr({
      convention: 12,
      format12: '{h:02.d}:{m:02.d} {z:s}',
      trigger: 'click'
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
    
    if (val == 'profile') {
      q('.massApplyForm').hide('fast');
      q('#massApplyProfileForm').show('fast');
    }
  }
};

/* Initializer */
jQuery(function() {
  Devices.init();
});
