/**
 * Geofences
 *
 * Constants and functions used on the Geofence Settings page.
 */
Geofences = {

  init: function() {

    q('a.delete').live('click', function() {
      q('#removeGeofence').find('form').attr('action', this.href).end()
                        .dialog('open');
      return false;
    });
    
    q("#removeGeofence").dialog({
      title: 'Remove Geofence',
      modal: true,
      autoOpen: false,
      resizable: false,
      width: 450,
      buttons: {
        'Yes, delete this geofence': Geofences.destroy,
        'No, do not delete': function() { q(this).dialog('close'); }
      }
    });

  }
  ,
  /**
   * Delete an existing geofence from the system
   */
  destroy: function() {
    var _this = q(this);
    
    _this.dialogLoader().show();
    _this.find('form').submit();
    
    return false;
  }
}

/* Initializer */
jQuery(function() {
  Geofences.init();
});
