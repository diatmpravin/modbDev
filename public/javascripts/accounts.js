/**
 * Accounts
 *
 * Javascript for the Account Settings page.
 *
 * Remember: jQuery = q() or $q()!
 */
Accounts = {
  init: function() {
    q('#cancelDialog').dialog({
      title: 'Cancel Account',
      modal: true,
      autoOpen: false,
      resizable: false,
      width: 450,
      buttons: {
        'Yes, cancel my account': Accounts.cancel,
        'No, do not cancel': function() { q(this).dialog('close'); }
      },
      close: function() { q(this).errors().find('form').resetForm(); }
    })
    .find('form').submit(function() { return false; }).end()
    .siblings('.ui-dialog-buttonpane').prepend('<div class="loading"></div>');
    
    q('a.cancelAccount').click(function() {
      q('#cancelDialog').dialog('open');
    });
    
    q('a.save').click(function() {
      q(this).closest('form').submit();
      return false;
    });

    q('a.reup').click(Accounts.reupSubscription);

    q('#paymentDialog').dialog({
      title: 'Payment Details',
      modal: true,
      autoOpen: false,
      resizable: false,
      width: 450,
      buttons: {
        'Close': function() { q(this).dialog('close'); }
      }
    });

    q('#oldPayments').change(function() {
      var paymentId = q("option:selected", this).val();

      // Ignore the "Select Date" optoin
      if (paymentId == "0") { return; }

      q(".busy").show();

      q.ajax({
        type: "GET",
        url: "/payments/" + paymentId,
        success: function(body) {
          q("#paymentDialog").html(body).dialog('open');;
        },
        complete: function() {
          q(".busy").hide();
        }
      });  
    });
  }
  ,
  cancel: function() {
    var _this = q(this);
    
    _this.find('form').ajaxSubmit({
      dataType: 'json',
      beforeSubmit: function() {
        _this.siblings('.ui-dialog-buttonpane').find('.loading').show();
      },
      error: function() {
        // error, do nothing
      },
      success: function(json) {
        _this.siblings('.ui-dialog-buttonpane').find('.loading').hide();
        if (json.status == 'success') {
          _this.dialog('close');
          location.href = '/logout';
        } else {
          _this.errors(json.error);
        }
      }
    });
  }
  ,
  reupSubscription: function() {
    q(this).closest("form").submit();
    return false;
  }
};

/* Initializer */
jQuery(function() {
  Accounts.init();
});
