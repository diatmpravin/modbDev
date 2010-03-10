/**
 * Global
 *
 * Constants and functions used on every page.
 *
 * Remember: jQuery = q() or $q()!
 */
Global = {
  init: function() {
    q('a.close').live('click', Global.closeNotice);
    
    q('#header ul.sf-menu').superfish({delay:500});
    
    q('a.help').live('click', function() {
      return false;
    });

    q('.corners').corners('transparent'); 
    
    q('a.continue').click(function() {
      if(q(this).attr("href") == "#") {
        q(this).closest('form').submit();
        return false;
      }
    });
    
    // Make sure any form that's submitted is only submitted once
    q("form").bind("submit", function() {
      if(q(this).attr("class") == "multiSubmit") {
        return true;
      }

      if(!q(this).data('submitted')) {
        q(this).data('submitted', true);
        return true;
      } else {
        return false;
      }
    });
    
    Global.initTabs();
  }
  ,
  closeNotice: function() {
    var _div = q(this).parents('div:first');
    _div.slideUp('fast', function() {
      _div.remove();
    });
  }
  ,
  /**
   * Find all hidden tabnavs and hook up show/hide event handlers for them.
   * Each subnav has an id of 'something_tabnav'. The associated list element
   * in the main tabnav will have a class with the same name.
   */
  initTabs: function() {
    Global.primaryTab = q('#header_tabnav li.active');
    Global.primarySubtab = q('.tabnav:visible');
    
    q('.tabnav:hidden').each(function() {
      var id = q(this).attr('id');
      var subtabId = '#' + id;
      var linkSelector = '#header_tabnav li.' + id;
      
      // When mouse enters a main tab, make it appear active and show the
      // appropriate subnav.
      q(linkSelector).bind('mouseenter', {subtab: q(subtabId)}, function(e) {
        q(this).addClass('active').siblings().removeClass('active');
        e.data.subtab.show().siblings('.tabnav').hide();
      });
      
      // When mouse leaves a main tab, revert to default UNLESS the user
      // is trying to select a link in the subnav.
      q(linkSelector).mouseleave(function(e) {
        if (q(e.relatedTarget).closest('.tabnav').length == 0) {
          Global.primaryTab.addClass('active').siblings().removeClass('active');
          Global.primarySubtab.show().siblings('.tabnav').hide();
        }
      });
      
      // When mouse leaves a subnav, revert to default.
      q(subtabId).mouseleave(function() {
        Global.primaryTab.addClass('active').siblings().removeClass('active');
        Global.primarySubtab.show().siblings('.tabnav').hide();
      });
    });
  }
}

if (!Array.prototype.indexOf) {
  Array.prototype.indexOf = function (obj, fromIndex) {
    if (fromIndex == null) {
      fromIndex = 0;
    } else if (fromIndex < 0) {
      fromIndex = Math.max(0, this.length + fromIndex);
    }
    for (var i = fromIndex, j = this.length; i < j; i++) {
      if (this[i] === obj)
      return i;
    }
    return -1;
  };
}

/**
 * Inject from http://katesgasis.com/2009/08/13/ruby-like-syntax-for-javascript-array-functions/
 */
if(!Array.prototype.inject) {
  Array.inject = function(a, init, fn){
    a.each(function(e){
      init = fn(init, e); 
    });
    return init;
  };

  Array.prototype.inject = function(init, fn){
    return Array.inject(this, init, fn);
  };
}

/* Initializer */
jQuery(function() {
  Global.init();
});

/* Plugins and Utilities */

/**
 * .errors(list)
 *
 * Call .errors() on a container element that you would like to display
 * errors in -- typically a jQuery dialog box. Given either a string or
 * an array of strings, .errors() will add the appropriate number of divs
 * with class 'error' to the top of the container specified.
 *
 * Calling errors() with no parameters will clear errors from the container.
 */
jQuery.fn.errors = function(o) {
  this.find('.error').remove();
  if (jQuery.isArray(o)) {
    var h = '';
    for(var i = 0; i < o.length; i++) {
      h += '<div class="error">' + o[i] + '</div>';
    }
    this.prepend(h);
  } else if (typeof o != 'undefined') {
    this.prepend('<div class="error">' + o + '</div>');
  }
  return this;
};

/**
 * .clearRailsForm()
 *
 * Need a better name for this. This is an attempt to encapsulate "clearing"
 * a Rails form, which includes clearing any input fields and stripping away
 * any error text and error styling.
 *
 * Can be called on any container, but most likely a form.
 */
jQuery.fn.clearRailsForm = function() {
  this.clearForm()
      .errors()
      .find('.loading').hide().end()
      .find('.fieldWithErrors').each(function() {
        q(this).replaceWith(this.childNodes);
      }).end()
      .find('.formError').remove();
};

/**
 * .dialogLoader()
 *
 * Call on a jQuery dialog pane to add a loading div (hidden by default) to the
 * lower left inside the button row.  Subsequent calls on the same dialog will
 * return the existing loading div.
 *
 * NEW: Try calling .dialogLoader(true) instead of .dialogLoader().show().
 * In addition to showing the loader, this will disable the dialog buttons.
 * Passing false will hide the loader and re-enable the dialog buttons.
 */
jQuery.fn.dialogLoader = function(showLoader) {
  var loader = q(this).siblings('.ui-dialog-buttonpane').find('.loading');
  if (loader.length == 0) {
    loader = q('<div class="loading"></div>').prependTo(
      q(this).siblings('.ui-dialog-buttonpane')
    );
  }
  
  if (typeof(showLoader) != 'undefined') {
    if (showLoader) {
      loader.show().siblings().attr('disabled', true);
    } else {
      loader.hide().siblings().attr('disabled', false);
    }
  }
  
  return loader;
};

/**
 * .fitWindow(function(width, height))
 *
 * Register an element as being resizable, aka hooking into the
 * 'resize' event, allowing elements on the page to update
 * to fit the browser window size.
 *
 * function should take two parameters: width and height. Use this
 * callback to do the actual resizing of elements as necessary.
 *
 * I was going to go with .resizable, but jquery UI has that taken.
 */
jQuery.fn.fitWindow = function(callback) {
  var _self = q(this);
  q(window).resize(function(event) {
    callback(
      q(window).width(),
      q(window).height() - _self.offset().top - 1
    );
  });

  // And run once to ensure a good start case
  q(window).resize();
};

/**
 * .groupSelect()
 *
 * Take an ordered list of groups and turn it into a group select widget,
 * with appropriate select all/none/some functionality.
 *
 * If you want to submit the list of checked groups to a form, just include
 * a checkbox input inside each li - it will be checked and unchecked as
 * appropriate.
 *
 * This method doesn't handle the look (stylesheet will take care of that).
 */
jQuery.fn.groupSelect = function() {
  // Check/uncheck rows when clicked
  q(this).find('li').click(function() {
    var self = q(this);
    
    if (self.hasClass('checked')) {
      self.find('li').andSelf().removeClass('checked halfchecked');
      self.find('input').attr('checked', false);
    } else {
      self.find('li').andSelf().removeClass('halfchecked').addClass('checked');
      self.find('input').attr('checked', true);
    }
    
    self.parents('li').removeClass('halfchecked checked')
        .children('input').attr('checked', false).end()
        .filter(':has(li.checked)').addClass('halfchecked');
    
    return false;
  });
  
  // Collapse and expand group lists when arrow is clicked
  q(this).find('span.collapsible').click(function() {
    q(this).toggleClass('open').toggleClass('closed');
    q(this).siblings('ol').toggle(q(this).hasClass('open'));
    
    return false;
  });
  
  // Hide the collapse/expand arrow for leaf rows
  q(this).find('li:not(:has(li)) span.collapsible').hide();
  
  // Check all rows that should start as selected
  q(this).find('input:checked')
         .parent().addClass('checked')
         .find('li').addClass('checked').end()
         .parents('li:not(.checked)').addClass('halfchecked');
  
  // "Open" the tree for all pre-selected rows, to save time
  q(this).find('li:has(li.checked) > span.collapsible').click();
};

/**
 * .sort(sort_fn)
 *
 * Given a sorting function sort_fn(a,b), do an in-place sort of all the
 * immediate children in the DOM. This function is intended to be called
 * on the CONTAINER element, and assumes all children will be sorted.
 *
 * Discussion & original source: http://bit.ly/afdKjY
 *
 * Example (sort all li's in an ordered list by id):
 *   q('ol').sort(function(a,b) {
 *     return a.attr('id') < b.attr('id') ? 1 : -1;
 *   });
 */
jQuery.fn.sort = function(sort_fn) {
  this.each(function(index, o) {
    [].sort.apply(jQuery(o).children(), [sort_fn]).appendTo(o);
  });
};
