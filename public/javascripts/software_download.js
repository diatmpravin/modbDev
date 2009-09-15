/**
 * Software Download
 *
 * Constants and functions used for downloading phone software.
 *
 * Remember: jQuery = q() or $q()!
 */
SoftwareDownload = {
  init: function() {
    q('.downloadPhoneSoftware').click(function() {
      q('#downloadDialog').dialog('open');
      return false;
    });
    q('.activatePhoneSoftware').click(function() {
      q('#activateDialog').dialog('open');
      return false;
    });
    
    q('#downloadDialog').dialog({
      title: 'Download Phone Software',
      modal: true,
      width: 380,
      resizable: false,
      autoOpen: false,
      buttons: {
        'Send me a text message': SoftwareDownload.download,
        'Cancel': function() { q(this).dialog('close'); }
      },
      close: SoftwareDownload.resetDialog
    })
    .find('form').submit(function() { return false; }).end()
    .siblings('.ui-dialog-buttonpane').prepend('<div class="loading"></div>');
    
    q('#activateDialog').dialog({
      title: 'Activate Phone Software',
      modal: true,
      width: 380,
      resizable: false,
      autoOpen: false,
      buttons: {
        'Activate': SoftwareDownload.activate,
        'Cancel': function() { q(this).dialog('close'); }
      },
      close: SoftwareDownload.resetDialog
    })
    .find('form').submit(function() { return false; }).end()
    .siblings('.ui-dialog-buttonpane').prepend('<div class="loading"></div>');
  }
  ,
  download: function() {
    var _this = q(this);
    
    _this.find('form').ajaxSubmit({
      dataType: 'json',
      type: 'put',
      beforeSubmit: function() {
        _this.siblings('.ui-dialog-buttonpane').find('.loading').show();
      },
      success: function(json) {
        _this.siblings('.ui-dialog-buttonpane').find('.loading').hide();
        if (json.status == 'success') {
          q('#downloadDialog').dialog('close');
          q('#activateDialog').dialog('open');
        } else {
          q('#downloadDialog').errors(json.error);
        }
      }
    });
  }
  ,
  activate: function() {
    var _this = q(this);
    
    q('#activation_code').val(q('#activation_code').val().toUpperCase());
    _this.find('form').ajaxSubmit({
      dataType: 'json',
      type: 'post',
      beforeSubmit: function() {
        _this.siblings('.ui-dialog-buttonpane').find('.loading').show();
      },
      success: function(json) {
        _this.siblings('.ui-dialog-buttonpane').find('.loading').hide();
        if (json.status == 'success') {
          q('#activateDialog').dialog('close');
          location.reload();
        } else {
          q('#activateDialog').errors(json.error);
        }
      }
    });
  }
  ,
  resetDialog: function() {
    q(this).errors().find('form').resetForm();
  }
};

/* Initializer */
jQuery(function() {
  SoftwareDownload.init();
});