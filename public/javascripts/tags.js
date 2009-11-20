/**
 * Tags
 *
 * Used on any page with a tag-selection interface.  This script initializes
 * itself, but if used on a page with multiple tag interfaces you may need to
 * make additional calls to Tags.prepare().
 *
 * The loading page should pre-load tags as an array of strings and put them in
 * Tags.source, for speedy auto-complete. 
 * 
 * If the controller chooses not to pre-load the tags (in the case of >1000 tags,
 * for example), the tag box will auto-complete using json calls to the Tags
 * controller instead.
 */
Tags = {
  source: null,
  
  init: function() {
    q('.tags a.add').live('click', Tags.displayForm);
    q('.tags a.remove').live('click', Tags.removeTag);
    
    q('#tagDialog').dialog({
      title: 'Enter New Tag',
      modal: true,
      autoOpen: false,
      resizable: false,
      buttons: {
        'Add Tag': Tags.createTag,
        'Cancel': function() { q(this).dialog('close'); }
      },
      close: function() { }
    });
    
    q('.tagEntry').live('keypress', function(e) {
      // Capture ENTER and submit dialog
      if (e.which == 13) {
        Tags.addTag(q(this).closest('ul'), this.value);
        this.value = '';
        this.focus();
        
        return false;
      }
    });
    
    Tags.prepare();
  }
  ,
  /**
   * Display the new tag dialog form.
   */
  displayForm: function() {
    q('#tagDialog').dialog('open')
                   .data('tagList', q(this).closest('ul'));
    return false;
  }
  ,
  /**
   * Creates a new tag on the server side, then updates the tag list.
   */
  createTag: function() {
    var _this = q(this);
    
    _this.find('form').ajaxSubmit({
      dataType: 'json',
      beforeSubmit: function() { _this.dialogLoader().show(); },
      complete: function() { _this.dialogLoader().hide(); },
      success: function(json) {
        if (json.status == 'success') {
          Tags.addTag(
            _this.data('tagList'), json.id, json.name
          );
          _this.dialog('close');
        } else {
          _this.errors(json.error);
        }
      }
    });
  }
  ,
  /**
   * Helper method that adds a new tag to the tag list.
   */
  addTag: function(list, text) {
    /* Uses the name of the tag input field to create each new entry. On
       submit, the controller will see this is an array of tag names. */
    var field_name = list.find('.tagEntry').attr('name');
    
    /* If the tag is already in the list, highlight it. */
    var tags = list.find('li:first').siblings().find('input');
    for(var i = 0; i < tags.length; i++) {
      if (tags[i].value == text) {
        q(tags[i]).closest('li')
                  .stop()
                  .css('background-color', '#ffffaa')
                  .animate({backgroundColor: 'transparent'}, 1000);
        return;
      }
    }
    
    /* If the tag isn't in the list, add it and slide down. */
    q('<li style="display:none"><a href="#" class="remove"></a><span>' + text + '</span>' +
      '<input type="hidden" name="' + field_name + '" value="'+ text + '"/></li>')
      .insertAfter(list.find('li:first'))
      .show('fast');
  }
  ,
  /**
   * Remove a tag from the tag list.
   */
  removeTag: function() {
    var _tag = q(this).closest('li');
    
    _tag.hide('fast', function() {
      _tag.remove();
    });
    
    return false;
  }
  ,
  /**
   * The user is choosing a tag from the drop-down, so add it to the tag list
   * and remove it from the drop-down.
   */
  select: function() {
    var _this = q(this);
    if (_this.val()=='') {
      return;
    }
    
    var _ul = q(this).closest('ul');
    Tags.addTag(
      _ul, this.options[this.selectedIndex].value, this.options[this.selectedIndex].text
    );
    
    _this.find('option:selected').remove();
    _this.val('');
  }
  ,
  /**
   * Prepare the auto-complete handler for any inputs in the given container.
   * Defaults to the entire page if no container is passed.
   */
  prepare: function(container) {
    if (Tags.source) {
      q(container || null).find('.tagEntry').autocomplete(Tags.source, {
        max: 10
      });
    } else {
      q(container || null).find('.tagEntry').autocomplete('/tags', {
        dataType: 'json',
        max: 10,
        parse: function(json) {
          // Convert each json call into the goofy format they expect.
          return q.map(json, function(item) {
            return {data: [item, item], value: item, result: item};
          });
        }
      });
    }
  }
};

/* Initializer */
jQuery(function() {
  Tags.init();
});
