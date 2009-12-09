/**
 * Device Profiles
 *
 * Constants and functions used on the Device Profiles page.
 */
DeviceProfiles = {
  init: function() {
    q('a.delete').live('click', function() {
      q('#removeProfile').find('form').attr('action', this.href).end()
                         .dialog('open');
      return false;
    });
    
    q('#profiles_all').attr('checked', false).click(function() {
      q('input[name=profiles]').attr('checked', this.checked);
    });
    q('input[name=profiles]').attr('checked', false).click(function() {
      q('#profiles_all').attr('checked', false);
    });
    
    q("#removeProfile").dialog({
      title: 'Remove Vehicle Profile',
      modal: true,
      autoOpen: false,
      resizable: false,
      width: 450,
      buttons: {
        'Yes, remove this profile': DeviceProfiles.destroy,
        'No, do not remove': function() { q(this).dialog('close'); }
      }
    });
    
    /* editing alert settings */
    q('.alertInfo input[type=checkbox]').live('click', function() {
      q(this).siblings('.extra').toggle(this.checked);
      
      DeviceProfiles.initTimepickr(q(this).parent());
    });
    
    DeviceProfiles.initTimepickr(q('.alertInfo'));
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
  destroy: function() {
    var _this = q(this);
    
    _this.dialogLoader().show();
    _this.find('form').submit();
    
    return false;
  }
};

/* Initializer */
jQuery(function() {
  DeviceProfiles.init();
});
