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
    
    q('#welcome ul.sf-menu').superfish({delay:500});
    
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

  }
  ,
  closeNotice: function() {
    var _div = q(this).parents('div:first');
    _div.slideUp('fast', function() {
      _div.remove();
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
 */
jQuery.fn.dialogLoader = function() {
  var loader = q(this).siblings('.ui-dialog-buttonpane').find('.loading');
  if (loader.length == 0) {
    loader = q('<div class="loading"></div>').prependTo(
      q(this).siblings('.ui-dialog-buttonpane')
    );
  }
  return loader;
}

/**
 * .fitWindow(function)
 *
 * Register an element as being resizable, aka hooking into the
 * 'resize' event, allowing elements on the page to update
 * to fit the browser window size.
 *
 * function should take two parameters: height and width. These will
 * be the new height and new width of the window.
 *
 * I was going to go with .resizable, but jquery UI has that taken.
 */
jQuery.fn.fitWindow = function(callback) {
  var _self = q(this);
  q(window).resize(function(event) {
    callback.call(
      _self,
      q(window).height() - _self.position().top - 1,
      q(window).width()
    );
  });
}
