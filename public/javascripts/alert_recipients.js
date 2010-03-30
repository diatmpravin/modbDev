/**
 * Alert Recipients
 *
 * Constants and functions used when dealing with alert recipients. Used by
 * multiple pages (Geofences, Vehicles, etc.).
 *
 * Remember: jQuery = q() or $q()!
 */
AlertRecipients = {
  // Default field name for the alert recipients. Can (should) be overriden by
  // creating a hidden field named "alertFieldName" within the alerts div.
  fieldName: 'alert_recipient_ids[]',

  init: function() {
    q('#newAlertRecipient').dialog({
      title: 'New Alert Recipient',
      modal: true,
      autoOpen: false,
      width: 350,
      buttons: {
        'Save': AlertRecipients.create,
        'Cancel': AlertRecipients.cancel
      },
      close: AlertRecipients.resetForm
    })
    .siblings('.ui-dialog-buttonpane').prepend('<div class="loading"></div>');
    
    q('#newAlertRecipient .email_radio').click(AlertRecipients.newEmail);
    q('#newAlertRecipient .phone_radio').click(AlertRecipients.newPhone);
    q('div.alerts a.remove').live('click', AlertRecipients.remove);
    q('div.alerts a.add').live('click', AlertRecipients.displayForm);
    
    AlertRecipients.prepare();
  }
  ,
  newEmail: function() {
    q('#newAlertRecipient .phone').hide();
    q('#newAlertRecipient .email').show().find('input')[0].focus();
  }
  ,
  newPhone: function() {
    q('#newAlertRecipient .email').hide();
    q('#newAlertRecipient .phone').show().find('input')[0].focus();
  }
  ,
  create: function() {
    var _this = q(this);
    
    _this.find('form').ajaxSubmit({
      dataType: 'json',
      beforeSubmit: function() {
        _this.siblings('.ui-dialog-buttonpane').find('.loading').show();
      },
      success: function(json) {
        _this.siblings('.ui-dialog-buttonpane').find('.loading').hide();
        if (json.status == 'success') {
          AlertRecipients.add(
            _this.data('alertList'), json.id, json.display_string
          );
          _this.dialog('close');
        } else {
          _this.errors(json.error);
        }
      }
    });
  }
  ,
  cancel: function() {
    q(this).dialog('close');
  }
  ,
  resetForm: function() {
    q(this).errors().find('form').resetForm();
  }
  ,
  prepare: function(container) {
    if (container) {
      q(container).find('div.alerts select.recipientSelect:not(.evented)').
        change(AlertRecipients.select).addClass('evented').val('');
    } else {
      q('div.alerts select.recipientSelect:not(.evented)').
        change(AlertRecipients.select).addClass('evented').val('');
    }
  }
  ,
  select: function() {
    var _this = q(this);
    if (_this.val()=='') {
      return;
    }
  
    AlertRecipients.add(
      _this.closest('ul'),
      this.options[this.selectedIndex].value,
      this.options[this.selectedIndex].text
    );
    
    _this.find('option:selected').remove();
    _this.val('');
  }
  ,
  add: function(list, id, text) {
    var fieldName = list.closest('div.alerts').find('input:first').val() ||
      AlertRecipients.fieldName;
    
    list.find('li:last').before(
      '<li><a href="#" class="remove"></a><span>' + text + '</span>' +
      '<input type="hidden" name="' + fieldName + '" value="' +
      id + '" class="id"/></li>'
    );
  }
  ,
  displayForm: function() {
    q('#newAlertRecipient').dialog('open')
                           .data('alertList', q(this).closest('ul'))
                           .find('.email_radio').click();
    
    return false;
  }
  ,
  remove: function() {
    var _this = q(this);
    var _alert = _this.closest('li');
    var _id = _this.siblings('input.id');
    if (_id.length >= 1) {
      _this.closest('div.alerts').find('select.recipientSelect').append(
        '<option value="' + _id.val() + '">' + _alert.find('span').html() + '</option>'
      );
    }
    _alert.hide('fast', function() {
      _alert.remove();
    });
    
    return false;
  }
};

/* Initializer */
jQuery(function() {
  AlertRecipients.init();
});
