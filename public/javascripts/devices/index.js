/**
 * Management of the /devices/index page
 */
if(typeof Devices == "undefined") {
  Devices = {};
}

Devices.Index = {
  listView: null
  ,
  init: function() {
    q('input.addVehicle').live('click', function() {
      q("#addDevice").dialog("open"); 
    });

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

    q("#removeDevice").dialog({
      title: 'Remove Vehicle',
      modal: true,
      autoOpen: false,
      resizable: false,
      width: 450,
      buttons: {
        'Yes, remove this vehicle': Devices.Index.destroy,
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
        'Add this Vehicle': Devices.Index.create,
        'Cancel': function() { q(this).dialog('close').clearRailsForm(); }
      }
    });

    q(".showOnMap").click(Devices.Index.showOnMap);

    Devices.Index.listView = new ListView(q("#devicesList"));

    new MassApply({
      select: q("#mass_apply"),
      mapping: {
        'profile': '#massApplyProfileForm',
        'add_group': '#addToGroupForm',
        'remove_group': '#removeFromGroupForm'
      },
      getSelection: function() {
        return Devices.Index.listView.getSelected();
      }
    });
  }
  ,
  /**
   * Get the selected vehicles and show them on live look map
   *
   * TODO Make this more integrated into the page. Paths in
   * javascript just aren't right.
   */
  showOnMap: function() {
    var selected = Devices.Index.listView.getSelected();
    location.href = "/devices/live_look?device_ids=" + selected;
  }
  ,
  /**
   * Remove a vehicle from the account
   */
  destroy: function() {
    var _this = q(this);
    
    _this.dialogLoader().show();
    _this.find('form').submit();
    
    return false;
  } 
  ,
  /**
   * Add a vehicle to the system
   */
  create: function() {
    var _this = q(this);

    _this.find('form').ajaxSubmit({
      dataType: 'json',
      beforeSubmit: function() { _this.dialogLoader().show(); },
      complete: function() { _this.dialogLoader().hide(); },
      success: function(json) {
        if (json.status == 'success') {
          location.reload();
        } else {
          _this.errors(json.error);
        }
      }
    });
    
    return false;
  }
};

jQuery(Devices.Index.init);
