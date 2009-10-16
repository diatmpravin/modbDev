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
    
    q('#topnav ul.sf-menu').superfish({delay:500});
    
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
