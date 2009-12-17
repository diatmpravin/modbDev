/**
 * Users Index
 */
if (typeof Users == "undefined") {
  Users = {};
}

Users.Index = {
  init: function() {
    q('a.delete').live('click', function() {
      q('#removeUser').find('form').attr('action', this.href).end()
                      .dialog('open');
      return false;
    });
    
    q('#removeUser').dialog({
      title: 'Remove User',
      modal: true,
      autoOpen: false,
      resizable: false,
      width: 450,
      buttons: {
        'Yes, remove this user': Users.Index.destroy,
        'No, do not remove': function() { q(this).dialog('close'); }
      }
    });
  }
  ,
  /**
   * Delete a user.
   */
  destroy: function() {
    var _this = q(this);
    
    _this.dialogLoader().show();
    _this.find('form').submit();
    
    return false;
  }
};

jQuery(Users.Index.init);
