/**
 * Phones
 *
 * Constants and functions used on the Phone Settings page.
 *
 * See software_download.js for Download Phone Software & Activate Phone
 * Software functionality.
 *
 * Remember: jQuery = q() or $q()!
 */
Phones = {
  init: function() {
    q('div.phone a.editSettings').live('click', Phones.edit);
    q('div.phone a.delete').live('click', Phones.destroy);
    q('div.phone a.save').live('click', Phones.save);
    q('div.phone a.cancel').live('click', Phones.cancel);
    
    q('div.phone').live('mouseover', function() {
      q('div.view .buttons').hide();
      q(this).find('.buttons').show();
    }).live('mouseout', function() {
      q('div.view .buttons').hide();
    });
  }
  ,
  edit: function() {
    var _this = q(this);
    var _view = _this.parents('div.view');
    var _edit = _view.siblings('div.edit');
    
    _view.hide('normal');
    _edit.show('normal');
    
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
          Phones.updateView(_view, function() {
            _view.show('normal');
            _edit.hide('normal', function() {
              Phones.updateEditForm(_edit);
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
      
      _view.show('normal');
      _edit.hide('normal', function() {
        Phones.updateEditForm(_edit);
      });
    
    
    return false;
  }
  ,
  destroy: function() {
    var _view = q(this).closest('div.view');
    var _edit = _view.siblings('div.edit');
    
    _edit.find('form').ajaxSubmit({
      dataType: 'json',
      type: 'delete',
      beforeSubmit: function() { _view.find('.loading').show(); },
      success: function(json) {
        if (json.status == 'success') {
          var _phone = _view.closest('div.phone');
          _phone.hide('normal', function() {
            _phone.remove();
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
    });
  }
}

/* Initializer */
jQuery(function() {
  Phones.init();
});
