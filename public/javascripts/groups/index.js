/**
 * Groups
 *
 * Constants and functions used on the Group Settings page.
 *
 * Note: ideally, the editing would be in a pop-up, but Jason+I would have been stepping
 * on each others' toes. So for now it is an extra page.
 */
Groups = {
  dragging: false,
  
  init: function() {

    q('a.delete').live('click', function() {
      q('#removeGroup').find('form').attr('action', this.href).end()
                       .dialog('open');
      return false;
    });
    
    q('span.edit').live('click', function() {
      location.href = q(this).find('a').attr('href');
    });
    /*q('a.edit').live('click', Groups.edit); TODO*/
    
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

    q('#moveGroup').dialog({
      modal: true,
      autoOpen: false,
      resizable: false,
      width: 300,
      buttons: {
        'Move': Groups.move,
        'Cancel': function() { q(this).dialog('close'); }
      }
    });
    
    /*q('#editGroup').dialog({
      modal: true,
      autoOpen: false,
      resizable: false,
      width: 300,
      buttons: {
        'Save': Groups.save,
        'Cancel': function() { q(this).dialog('close').errors(); }
      }
    }); TODO */
    
    q(".viewDetails").live('click', Groups.toggleDetails);
    
    new Reports.Form({
      container: '#runReportForm',
      deviceField: 'input[name=group_ids]',
      getSelection: function() { return Groups.getSelected(); }
    });
    
    q('.groupList li').draggable({
      helper: 'clone',
      handle: 'span.handle',
      opacity:0.8,
      start: function() { Groups.dragging = true; },
      stop: function() { Groups.dragging = false; }
    });
    q('.groupList li').droppable({
      hoverClass: 'dropHover',
      greedy: true,
      tolerance: 'pointer',
      drop: function(event, ui) {
        Groups.confirmMove(ui.draggable, q(this));
      }
    });
    
    q('.groupList li').mouseover(function() {
      if (!Groups.dragging) {
        q(this).children('span.edit,span.handle').show();
      }
      
      return false;
    }).mouseout(function() {
      q('span.handle,span.edit').hide();
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
  confirmMove: function(dragGroup, dropGroup) {
    q('#moveGroup').data('dragGroup', dragGroup)
      .data('dropGroup', dropGroup)
      .find('form').attr('action', '/groups/' + dragGroup.attr('id').split('_')[1])
      .find('input.parent_id').val(dropGroup.attr('id').split('_')[1]);
    q('#moveGroup span.from').text(dragGroup.children('span.name').text());
    q('#moveGroup span.to').text(dropGroup.children('span.name').text());
    
    q('#moveGroup').dialog('open');
    q('span.handle').hide();
  }
  ,
  move: function() {
    var self = q(this);
    
    self.find('form').ajaxSubmit({
      dataType: 'json',
      beforeSubmit: function() {
        self.dialogLoader(true);
      },
      success: function(json) {
        self.dialogLoader(false);
        
        if (json.status == 'success') {
          self.dialog('close');
          
          // Get the sub-list, or create it if it isn't there
          var list = self.data('dropGroup').find('ol');
          if (list.length == 0) {
            list = q('<ol></ol>').appendTo(self.data('dropGroup'));
          }
          
          // Append the dropped element to the list, then sort alphabetically
          self.data('dragGroup').hide().appendTo(list);
          list.sort(function(a,b) {
            return q(a).children('span.name').text() > q(b).children('span.name').text() ? 1 : -1
          });
          self.data('dragGroup').show().effect('highlight', {}, 'slow');
        } else {
          self.errors(json.error);
        }
      }
    });
    
    return false;
  }
  ,
  /*edit: function() {
    q('#editGroup').html('Please wait...').dialog('open').dialogLoader(true);
    
    q.get(this.href, function(html) {
      q('#editGroup').html(html).dialogLoader(false);
    });
    
    return false;
  }
  ,
  update: function() {
    var self = q(this);
    
    self.find('form').ajaxSubmit({
      dataType: 'json',
      beforeSubmit: function() {
        self.dialogLoader(true);
      },
      success: function(json) {
        self.dialogLoader(false);
        
        if (json.status == 'success') {
          self.dialog('close');
          
          // blargh
        } else {
          // blargh
          self.errors(json.error);
        }
      }
    });
  } 
  , TODO */
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
