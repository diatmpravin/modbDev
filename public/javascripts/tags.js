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
 * for example), the tag box will auto-complete using json calls to the tags
 * controller instead.
 */
Tags = {
  source: null,
  
  init: function() {
    q('.tags a.remove').live('click', Tags.removeTag);
    
    q('.addTag').live('click', function() {
      var field = q(this).siblings('.tagEntry');
      Tags.addTag(q(this).closest('ul'), field.val());
      field.val('');
      field.focus();
      return false; 
    });

    q('.tagEntry').live('keypress', function(e) {
      // Capture ENTER and submit tag
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
   * Helper method that adds a new tag to the tag list.  If the tag already
   * exists, will highlight it temporarily instead.
   */
  addTag: function(list, text) {
    /* Uses the name of the tag input field to create each new entry. On
       submit, the controller will see this is an array of tag names. */
    var field_name = list.find('.tagEntry').attr('name');
    
    /* If the tag is already in the list, highlight it. */
    var tags = list.find('li:first').siblings().find('input');
    for(var i = 0; i < tags.length; i++) {
      if (tags[i].value == text) {
        q(tags[i]).closest('li').find('span')
                  .stop()
                  .css('background-color', '#ebfb4b')
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
