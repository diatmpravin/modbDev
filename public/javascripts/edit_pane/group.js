/**
 * Edit Pane - Group
 */
if (typeof EditPane == 'undefined') { EditPane = {}; }
if (typeof EditPane.Group == 'undefined') { EditPane.Group = {}; }

EditPane.Group = {
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
        'Move': EditPane.Group.move,
        'Cancel': function() { q(this).dialog('close'); }
      }
    });
    
    q("#removeGroup").dialog({
      modal: true,
      autoOpen: false,
      resizable: false,
      width: 450,
      buttons: {
        'Delete': EditPane.Group.remove,
        'Cancel': function() { q(this).dialog('close'); }
      }
    });
  },
  
  /**
   * Prepare the fancy sliders, buttons, and events for the edit pane. If
   * provided, load up the pane first with the given HTML.
   */
  initPane: function(html) {
    if (typeof(html) != 'undefined') {
      q('#edit_pane .edit').html(html);
    }
    
    // Pretty & clickable buttons
    q('#edit_pane .buttons').find('a, input').button();
    q('#edit_pane .buttons .cancel').click(EditPane.Group.cancel);
    q('#edit_pane .buttons .save').click(EditPane.Group.save);
    
    // Get the sliders ready (temporarily using a different file)
    Groups.init();
    
    return q('#edit_pane .edit');
  },
  
  /**
   * Show the edit form for a new group.
   */
  newGroup: function() {
    EditPane.clear().title('Create Group');
    DataPane.close();
    
    q.get(q(this).attr('href'), function(html) {
      EditPane.Group.initPane(html);
      EditPane.show();
    });
    
    return false;
  },
  
  /**
   * Show the edit form for the selected group.
   */
  edit: function() {
    EditPane.clear().title('Edit Group');
    DataPane.close();
    
    q.get(q(this).attr('href'), function(html) {
      q('#edit_pane').find('.loading').hide();
      
      EditPane.Group.initPane(html).show();
    });
    
    return false;
  },
  
  /**
   * Save the group and close the group edit form.
   */
  save: function() {
    var self = q(this);
    
    q('#edit_pane form').ajaxSubmit({
      dataType: 'json',
      beforeSubmit: function() { },
      success: function(json) {
        if (json.status == 'success') {
          // The application will return a new tree and tell us where to put it
          q('#' + json.id).closest('li').replaceWith(json.html);
          DataPane.updated(q('#' + json.id).closest('li'));
          
          //self.dialogLoader(false);
          
          DataPane.open();
          EditPane.title();
        } else {
          EditPane.Group.initPane(json.html);
        }
      }
    });
    
    return false;
  },
  
  /**
   * Close the group edit form without saving.
   */
  cancel: function() {
    DataPane.open();
    EditPane.title();
                    
    return false;
  },
  
  /**
   * Show the move confirmation dialog box.
   */
  confirmMove: function(dragGroup, dropGroup) {
    var dragId = dragGroup.attr('id').match(/.+_(\d*)/)[1]
    var dropId = dropGroup.attr('id').match(/.+_(\d*)/)[1]
    
    // Store references to the "dragged" and "dropped" groups, and update the
    // the move form so it can submit the correct ids.
    q('#moveGroup').data('dragGroup', dragGroup)
      .data('dropGroup', dropGroup)
      .find('form').attr('action', '/groups/' + dragId)
      .find('input.parent_id').val(dropId);
    
    // Insert the names of the two groups in some placeholder spans.
    q('#moveGroup span.from').text(dragGroup.find('span.name').text());
    q('#moveGroup span.to').text(dropGroup.find('span.name').text());
    
    q('#moveGroup').errors().dialog('open');
    
    return false;
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
          
          // The application will return a new tree and tell us where to put it
          q('#' + json.id).closest('li').replaceWith(json.html);
          DataPane.updated(q('#' + json.id).closest('li'));
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
          
          // The application will return a new tree and tell us where to put it
          q('#' + json.id).closest('li').replaceWith(json.html);
          DataPane.updated(q('#' + json.id).closest('li'));
        } else {
          self.errors(json.error);
        }
      }
    });
    
    return false;
  }
};
