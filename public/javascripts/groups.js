/**
 * Groups
 *
 * Constants and functions used on the Group Settings page.
 */
Groups = {

  init: function() {

    q('a.delete').live('click', function() {
      q('#removeGroup').find('form').attr('action', this.href).end()
                        .dialog('open');
      return false;
    });
    
    q("#removeGroup").dialog({
      title: 'Remove Group',
      modal: true,
      autoOpen: false,
      resizable: false,
      width: 450,
      buttons: {
        'Yes, delete this group': Groups.destroy,
        'No, do not delete': function() { q(this).dialog('close'); }
      }
    });

    new Reports.Form({
      container: '#runReportForm',
      deviceField: 'input[name=group_ids]',
      getSelection: function() { return Groups.getSelected(); }
    });
  }
  ,
  /**
   * Delete an existing group from the system
   */
  destroy: function() {
    var _this = q(this);
    
    _this.dialogLoader().show();
    _this.find('form').submit();
    
    return false;
  }
  ,
  /**
   * Return a list of currently selected groups.
   *
   * TODO: Replace with Jason's ListView construct?
   */
  getSelected: function() {
    return q('input[name=apply_to][checked=true]').fieldValue().join();
  }
}

/* Initializer */
jQuery(function() {
  Groups.init();
});
