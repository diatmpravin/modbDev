/**
 * Report Card
 */
if (typeof(ReportCard) == 'undefined') {
  ReportCard = {};
}

/**
 * Report Card Frame
 */
ReportCard.Frame = {
  init: function() {
    // When browser window resizes, adjust the size of the report card frame
    q('#frame').fitWindow(function(width, height) {
      q('#frame').height(height - 32 - 2);
    });
    
    // Adjust the padding of certain elements to reflect the scrollbar size
    var scrollbarSize = q('#data_pane').width() - q('#data_pane > ol').width();
    q('.scrollbar-fix').css('padding-right', function() {
      return parseInt(q(this).css('padding-right')) + scrollbarSize;
    });
    
    ReportCard.DataPane.init();
    ReportCard.Group.init();
  }
};

/**
 * Report Card Data Pane
 */
ReportCard.DataPane = {
  /**
   * Initialize the Report Card "data pane", which contains the group tree and
   * the report card table.
   */
  init: function() {
    // Startup: hide collapsible arrows for empty groups
    q('li:not(:has(li)) span.collapsible').hide();
  
    // Allow user to toggle collapsible groups open and closed
    q('span.collapsible').live('click', function() {
      var self = q(this);
      if (self.closest('li').children('ol').toggle().css('display') == 'none') {
        self.addClass('closed');
      } else {
        self.removeClass('closed');
      }
    });
    
    // Allow user to edit groups
    q('div.group a.edit').live('click', ReportCard.Group.edit);
    
    
    // Allow user to delete groups
    q('div.group a.delete').live('click', ReportCard.Group.confirmRemove);
  },
  
  /**
   * Collapse the data pane, hiding the report card table and showing only
   * the group tree on the left. This allows other panes to be visible on the
   * right.
   */
  close: function() {
    // "Fix" the width of the report card table so it doesn't resize
    q('#data_pane > ol').css('width', function() { return q(this).width() + 'px'; });
    
    // Collapse the data pane
    q('#data_pane').animate({width:280}, {duration:'fast'});
    
    return this;
  },
  
  /**
   * Open the data pane, hiding any existing panes and showing the report card
   * table.
   */
  open: function() {
    // Open the data pane
    q('#data_pane').animate({width:'100%'}, {duration:'fast'});
    
    // "Unfix" the width of the report card table so it can be resized
    q('#data_pane > ol').css('width', 'auto');
    
    return this;
  },
  
  /**
   * Display an alternate titlebar for the right pane. Calling with null or
   * no parameters will reset the bar to the normal report card display.
   */
  title: function(newTitle) {
    if (typeof(newTitle) == 'undefined' || newTitle == null) {
      q('#report_card_header div.title').hide('fast');
      q('#report_card_header div.data').show('fast');
    } else {
      q('#report_card_header div.title span').html(newTitle);
      q('#report_card_header div.data').hide('fast');
      q('#report_card_header div.title').show('fast');
    }
    
    return this;
  }
};

/**
 * Report Card Group
 */
ReportCard.Group = {
  /**
   * Setup group dialog boxes and drag/drop events.
   */
  init: function() {
    q('#moveGroup').dialog({
      modal: true,
      autoOpen: false,
      resizable: false,
      width: 300,
      buttons: {
        'Move': ReportCard.Group.move,
        'Cancel': function() { q(this).dialog('close'); }
      }
    });
    
    q("#removeGroup").dialog({
      modal: true,
      autoOpen: false,
      resizable: false,
      width: 450,
      buttons: {
        'Delete': ReportCard.Group.remove,
        'Cancel': function() { q(this).dialog('close'); }
      }
    });
  },
  
  /**
   * Show the edit form for the selected group.
   */
  edit: function() {
    q('#edit_pane').find('.edit').hide().end()
                   .find('.loading').show();
    
    ReportCard.DataPane.close().title('Edit Group');
    
    q.get(q(this).attr('href'), function(html) {
      q('#edit_pane').find('.loading').hide().end()
                     .find('.edit').html(html).show();
      
      q('#edit_pane a.cancel').click(ReportCard.Group.cancel);
    });
    
    return false;
  },
  
  /**
   * Close the group edit form without saving.
   */
  cancel: function() {
    ReportCard.DataPane.open().title();
    
    q('#edit_pane').find('.edit').hide().empty().end()
                   .find('.loading').show();
                    
    return false;
  },
  
  /**
   * Show the move confirmation dialog box.
   */
  confirmMove: function(dragGroup, dropGroup) {
    // Store references to the "dragged" and "dropped" groups, and update the
    // the move form so it can submit the correct ids.
    q('#moveGroup').data('dragGroup', dragGroup)
      .data('dropGroup', dropGroup)
      .find('form').attr('action', '/groups/' + dragGroup.attr('id').split('_')[1])
      .find('input.parent_id').val(dropGroup.attr('id').split('_')[1]);
    
    // Insert the names of the two groups in some placeholder spans.
    q('#moveGroup span.from').text(dragGroup.children('span.name').text());
    q('#moveGroup span.to').text(dropGroup.children('span.name').text());
    
    q('#moveGroup').dialog('open');
  },
  
  /**
   * Move a group from one position to another.
   */
  move: function() {
    var self = q(this);
    
    self.find('form').ajaxSubmit({
      dataType: 'json',
      beforeSubmit: function() { self.dialogLoader(true); },
      success: function(json) {
        self.dialogLoader(false);
        
        if (json.status == 'success') {
          self.dialog('close');
          
          var dropGroupElement = self.data('dropGroup').parent();
          var dragGroupElement = self.data('dragGroup').parent();
          
          // Get the sub-list, or create it if it isn't there
          var list = dropGroupElement.find('ol');
          if (list.length == 0) {
            list = q('<ol></ol>').appendTo(dropGroupElement);
          }
          
          // Append the dropped element to the list, then sort alphabetically
          dragGroupElement.hide().appendTo(list);
          list.sort(function(a,b) {
            return q(a).children('div').children('span.name').text() > q(b).children('div').children('span.name').text() ? 1 : -1
          });
          dragGroupElement.show().effect('highlight', {}, 'slow');
        } else {
          self.errors(json.error);
        }
      }
    });
    
    return false;
  },
  
  /**
   * Show the remove confirmation dialog box.
   */
  confirmRemove: function() {
    q('#removeGroup').find('form').attr('action', this.href).end()
                     .dialog('open');
    
    return false;
  },
  
  /**
   * Remove the selected group from the list.
   */
  remove: function() {
    var self = q(this);
    
    self.find('form').ajaxSubmit({
      dataType: 'json',
      beforeSubmit: function() { self.dialogLoader(true); },
      success: function(json) {
        self.dialogLoader(false);
        
        if (json.status == 'success') {
          self.dialog('close');
          
          // The application will return a new "tree" for our direct ancestor,
          // and tell us where to put it.
          q('#' + json.id).replaceWith(json.html);
          ReportCard.DataPane.updated(q('#' + json.id));
          
        } else {
          self.errors(json.error);
        }
      }
    });
  }
};

/* Initialize */
jQuery(ReportCard.Frame.init);
