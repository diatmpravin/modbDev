/**
 * Devices
 *
 * Constants and functions used on the Device Settings page.
 *
 * Remember: jQuery = q() or $q()!
 */
Devices = {
  init: function() {
    q('input.addVehicle').live('click', Devices.newDevice);
    
    q('.device .view').live('mouseover', function() {
      q(this).find('.buttons').show();
    }).live('mouseout', function() {
      q(this).find('.buttons').hide();
    });
    
    q('div.device input.edit').live('click', Devices.edit);
    q('div.device input.delete').live('click', function() { 
      q("#removeDevice").dialog("open").data('device', q(this)); 
      return false;
    });
    q('div.device[id!=new] input.save').live('click', Devices.save);
    q('div.device[id!=new] input.cancel').live('click', Devices.cancel);

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
    
    q('td input[type=checkbox]').live("click", function() {
      q(this).closest('tr').find('td.extra').toggle(q(this).attr('checked'));

      Devices.initTimepickr(q(this).parents("div.edit"));
    });
  }
  ,
  initTimepickr: function(edit) {
    edit.find('td:visible input.timepick').timepickr({
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
  save: function() {
    var _this = q(this);
    var _edit = _this.closest('div.edit');
    var _view = _edit.siblings('div.view');
    
    _edit.find('form').ajaxSubmit({
      dataType: 'json',
      beforeSubmit: function() { _edit.find('.loading').show(); },
      success: function(json) {
        if (json.status == 'success') {
          Devices.updateView(_view, function() {
            _view.show('normal').closest('div.device').siblings().not('#new').show();
            _edit.hide('normal', function() {
              Devices.updateEditForm(_edit);
            });
          });
        } else {
          _edit.html(json.html);
        }
      }
    });
    
    return false;
  }
  ,
  cancel: function() {
    var _this = q(this);
    var _edit = _this.closest('div.edit');
    var _view = _edit.siblings('div.view');
    
    _view.show('normal').closest('div.device').siblings().not('#new').show();
    _edit.hide('normal', function() {
      Devices.updateEditForm(_edit);
    });
    
    return false;
  }
  ,
  destroy: function() {
    var _this = q(this),
        _view = _this.data("device").closest('div.view'),
        _edit = _view.siblings('div.edit');

    _edit.find('form').ajaxSubmit({
      dataType: 'json',
      type: 'delete',
      beforeSubmit: function() { _view.find('.loading').show(); },
      complete: function() { _view.find('.loading').hide(); _this.dialog('close'); },
      success: function(json) {
        if (json.status == 'success') {
          var _device = _view.closest('div.device');
          _device.hide('normal', function() {
            _device.remove();
          });
        } else {
          location.reload();
        }
      }
    });
    
    return false;
  }
  ,
  updateView: function(viewElem, callback) {
    q.get(viewElem.siblings('div.edit').find('form').attr('action'), function(html) {
      viewElem.html(html);
      if (typeof callback != 'undefined') {
        callback();
      }
    });
  }
  ,
  updateEditForm: function(editElem) {
    q.get(editElem.find('form').attr('action') + '/edit', function(html) {
      editElem.html(html);
      AlertRecipients.prepare(editElem);
    });
  }
}

/* Initializer */
jQuery(function() {
  Devices.init();
});
