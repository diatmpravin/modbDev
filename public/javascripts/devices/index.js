/**
 * Management of the /devices/index page
 */
if(typeof Devices == "undefined") {
  Devices = {};
}

Devices.Index = {
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

jQuery(function() {
  q('input.addVehicle').live('click', function() {
    q("#addDevice").dialog("open"); 
  });

  q('a.delete').live('click', function() {
    q('#removeDevice').find('form').attr('action', this.href).end()
                      .dialog('open');
    return false;
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
});
