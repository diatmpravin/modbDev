/**
 * Wizard
 *
 * Constants and functions used on all Wizard pages.
 *
 * Remember: jQuery = q() or $q()!
 */
Wizard = {
  init: function() {
    q('#removeDialog').dialog({
      title: 'Remove Tracker',
      modal: true,
      autoOpen: false,
      resizable: false,
      width: 450,
      buttons: {
        'Yes, remove this Tracker': Wizard.removeTracker,
        'No, keep Tracker': function() { q(this).dialog('close'); }
      }
    })
    .siblings('.ui-dialog-buttonpane').prepend('<div class="loading"></div>');
    
    q('a.remove').click(function() {
      q('#removeDialog').dialog('open').data('id', q(this).siblings('input').val());
      return false;
    });
    
    q('#livelook a').click(function() {
      q('form').submit();
      return false;
    });
  }
  ,
  removeTracker: function() {
    var _this = q(this);
    
    q.ajax({
      url: '/devices/' + _this.data('id'),
      dataType: 'json',
      type: 'delete',
      beforeSend: function() {
        _this.siblings('.ui-dialog-buttonpane').find('.loading').show();
      },
      success: function(json) {
        location.reload();
      }
    });
  }
}

/* Initializer */
jQuery(function() {
  Wizard.init();
});
