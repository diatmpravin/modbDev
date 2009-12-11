/**
 * Device Profiles - Index
 */
if (typeof DeviceProfiles == 'undefined') {
  DeviceProfiles = {};
};
DeviceProfiles.Index = {
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
        'Yes, remove this profile': DeviceProfiles.Index.destroy,
        'No, do not remove': function() { q(this).dialog('close'); }
      }
    });
  }
  ,
  /**
   * Submit the "Remove Profile" form.
   */
  destroy: function() {
    var _this = q(this);
    
    _this.dialogLoader().show();
    _this.find('form').submit();
    
    return false;
  }
};

/* Initializer */
jQuery(DeviceProfiles.Index.init);
