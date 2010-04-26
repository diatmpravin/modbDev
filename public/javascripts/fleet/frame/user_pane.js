/**
 * Fleet.Frame.UserPane
 *
 * The user pane
 *
 */
var Fleet = Fleet || {};
Fleet.Frame = Fleet.Frame || {};
Fleet.Frame.UserPane = (function(UserPane, Fleet, $) {
  var width = 280,
      pane,
      list,
      init = false;

  /**
   * init()
   *
   * Create and prepare the UserPane
   */
  UserPane.init = function() {
    if (init) {
      return UserPane;
    }

    // Create the user pane
    $('#frame').append('<div id="user_pane" class="hierarchy"><ol></ol></div>');

    // Store a reference to the pane
    pane = $('#user_pane');

    // list of users
    list = pane.children('ol');

    // Allow the user to toggle collapsible groups open and closed
    $('#user_pane div.group span.indent, #user_pane div.group span.collapsible').live('click', function() {
      var self = $(this).parent().children('span.collapsible');
      var _li = self.closest('li')
      if (_li.children('ol').toggle().css('display') == 'none') {
        self.addClass('closed');
      } else {
        self.removeClass('closed');
      }
    
      return true;
    });
      
    
    // click to edit user
    $('#user_pane li').live('click', function(event) {
      Fleet.Controller.focus.call(this);
    });

    init = true;
    return UserPane;
  };

  /**
   * showUsers(html)
   *
   * populate the pane
   */
  UserPane.showUsers = function(html) {
    list.html(html);
    
    // Hide collapsible arrows for empty groups
    list.find('li:not(:has(li)) span.collapsible').removeClass('collapsible').addClass('empty');

    return UserPane;
  };

  /**
   * open()
   * open(callback)
   *
   * Open the user pane.  If provided, call the callback after opening
   */
  UserPane.open = function(callback) {
    if ($.isFunction(callback)){
      pane.animate({width: width}, {
        duration: 400,
        complete: callback
      });
    } else {
      pane.animate({width: width}, {duration: 400});
    }
    
    return UserPane;
  };

  /*
   * close()
   * close(callback)
   *
   * Close the user pane.  If provided, call the callback after closing
   */
  UserPane.close = function(callback) {
    if ($.isFunction(callback)) {
      pane.animate({width: 0}, {
        duration: 400,
        complete: callback
      });
    } else {
      pane.animate({width: 0}, {duration: 400});
    }
    
    return UserPane;
  };
  
  /**
   * width()
   *
   * Return the current width of the user pane.
   */
  UserPane.width = function() {
    return pane.width();
  };

  return UserPane;
}(Fleet.Frame.UserPane || {}, Fleet, jQuery));
