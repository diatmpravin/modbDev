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

    q(".viewDetails").live('click', Groups.toggleDetails);
    
    new Reports.Form({
      container: '#runReportForm',
      deviceField: 'input[name=group_ids]',
      getSelection: function() { return Groups.getSelected(); }
    });
  }
  ,
  /**
   * View details of a given group
   */
  toggleDetails: function() {
    var href = q(this).attr('href'), 
        group = q(this).parent().parent().parent(),
        details = group.find(".details"); 

    if(group.find(".details:visible").length > 0) {
      details.slideUp("fast");
    } else {

      group.find(".loading").show(); 

      q.ajax({
        type: 'GET',
        url: href,
        complete: function() {
          group.find(".loading").hide();
        },
        success: function(body) {
          details.html(body).slideDown("fast");
        }
      });

    }

    return false;
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
   * TODO: Replace with Jason's ListView component?
   */
  getSelected: function() {
    return q('input[name=apply_to]:checked').fieldValue().join();
  }
};

/* Initializer */
jQuery(Groups.init);
