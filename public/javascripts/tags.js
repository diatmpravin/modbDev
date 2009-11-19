/**
 * Tags
 *
 * Used on any page with a tag-selection interface.  This script initializes
 * itself, but if used on a page with multiple tag interfaces you may need to
 * make additional calls to Tags.prepare().
 */
Tags = {
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
    
    q('#tagDialog input').live('keypress', function(e) {
      // Capture ENTER and submit dialog
      if (e.which == 13) {
        Tags.createTag.call(q('#tagDialog'), e);
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
  addTag: function(list, id, text) {
    list.find('li:last').before(
      '<li><a href="#" class="remove"></a><span>' + text + '</span>' +
      '<input type="hidden" name="trip[tag_ids][]" value="' +
      id + '" class="id"/></li>'
    );
  }
  ,
  /**
   * Remove a tag from the tag list and insert it back into the drop-down.
   */
  removeTag: function() {
    var _this = q(this);
    var _tag = _this.closest('li');
    var _id = _this.siblings('input.id');
    if (_id.length >= 1) {
      _this.closest('ul').find('select.tagSelect').append(
        '<option value="' + _id.val() + '">' + _tag.find('span').html() + '</option>'
      );
    }
    _tag.hide('normal', function() {
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
   * Prepare non-live event handlers for any select boxes in the given
   * container. If no argument is passed, will attempt to prepare the entire
   * page.
   */
  prepare: function(container) {
    if (container) {
      q(container).find('.tags select:not(.tagSelect)').
        change(Tags.select).addClass('tagSelect').val('');
    } else {
      q('.tags select:not(.tagSelect)').
        change(Tags.select).addClass('tagSelect').val('');
    }
  }
};

/* Initializer */
jQuery(function() {
  Tags.init();
});
