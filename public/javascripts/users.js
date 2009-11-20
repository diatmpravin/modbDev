/**
 * Users
 *
 * Constants and functions used on the User Management page.
 *
 * Remember: jQuery = q() or $q()!
 */
Users = {
  init: function() {
    q('input.addUser').live('click', Users.newUser);
    q('div.user[id=new] input.cancel').live('click', Users.cancelNew);
    q('div.user[id=new] input.save').live('click', Users.create);
    
    q('input.edit').live('click', Users.edit);
    q('div.user[id!=new] input.cancel').live('click', Users.cancel);
    q('div.user[id!=new] input.save').live('click', Users.save);
    q('input.delete').live('click', function() {
      q('#removeUser').dialog('open').data('user', q(this));
      return false;
    });
    
    q('#removeUser').dialog({
      title: 'Remove User',
      modal: true,
      autoOpen: false,
      resizable: false,
      width: 450,
      buttons: {
        'No, do not remove': function() {
          q(this).dialog('close');
        },
        'Yes, remove this user': Users.destroy,
      }
    });
  }
  ,
  newUser: function() {
    q('input.addUser').parent().hide('normal');
    q('#new').show('normal').siblings('.user').hide();
    return false;
  }
  ,
  create: function() {
    var _this = q(this);
    
    _this.closest('form').ajaxSubmit({
      dataType: 'json',
      beforeSubmit: function() { _this.find('.loading').show(); },
      success: function(json) {
        if (json.status == 'success') {
          location.reload();
        } else {
          q('#new').html(json.html);
        }
      }
    });
  }
  ,
  cancelNew: function() {
    var _new = q('#new');
    
    _new.hide('normal', function() {
      q.get('/users/new', function(html) {
        _new.html(html);
      });
    });
    q('input.addUser').parent().show('normal').siblings().not('#new').show();
    
    return false;
  }
  ,
  edit: function() {
    var _this = q(this);
    var _view = _this.parents('div.view');
    var _edit = _view.siblings('div.edit');
    
    _view.hide('normal').closest('div.user').siblings().hide();
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
          Users.updateView(_view, function() {
            _view.show('normal').closest('div.user').siblings().not('#new').show();
            _edit.hide('normal', function() {
              Users.updateEditForm(_edit);
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
    
    _view.show('normal').closest('div.user').siblings().not('#new').show();
    _edit.hide('normal', function() {
      Users.updateEditForm(_edit);
    });
    
    return false;
  }
  ,
  destroy: function() {
    var _this = q(this);
    var _view = _this.data('user').closest('div.view');
    var _edit = _view.siblings('div.edit');
    
    q('#removeUser').dialog('close');
    
    _edit.find('form').ajaxSubmit({
      dataType: 'json',
      type: 'delete',
      beforeSubmit: function() { _view.find('.loading').show(); },
      success: function(json) {
        if (json.status == 'success') {
          var _user = _view.closest('div.user');
          _user.hide('normal', function() {
            _user.remove();
          });
        } else {
          location.reload();
        }
      }
    });
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
  Users.init();
});
