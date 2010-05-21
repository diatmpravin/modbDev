/**
 * Fleet.Frame.UserPane
 *
 * The user pane
 *
 */
var Fleet = Fleet || {};
Fleet.Frame = Fleet.Frame || {};
Fleet.Frame.UserPane = (function(UserPane, Fleet, $) {
  var width = '100%',
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
    
      return false;
    });
      
    // User can edit a user
    $('#user_pane a.edit').live('click', function() {
      return Fleet.Controller.edit.call(this);
    });

    // User can remove a user
    $('#user_pane a.delete').live('click', function() {
      return Fleet.Controller.remove.call(this);
    });

    // User can add a user in a group
    $('#user_pane a.new').live('click', function() {
      return Fleet.Controller.newUser.call(this);
    });
    
    // click to edit user as default focus action?
    //$('#user_pane li').live('click', function(event) {
    //  Fleet.Controller.focus.call(this);
    //});

    init = true;
    return UserPane;
  };

  /**
    * initPane()
    *
    */
  UserPane.initPane = function() {
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


    // Allow user to drag users around
    list.find('div.user:not(.undraggable)').draggable({
      helper: 'clone',
      handle: 'div.listing',
      opacity: 0.8,
      distance: 8
    });

    // Allow user to drop stuff onto groups
    list.find('div.group').droppable({
      hoverClass: 'drop-hover',
      greedy: true,
      drop: function(event, ui) {
        Fleet.UserController.move(ui.draggable, $(this));
      }
    });

    return UserPane;
  };

  UserPane.clearBindings = function() {
    list.find('div.group').droppable('destroy');
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

  /**
   * editEnabled(bool)
   *
   * Set edit-enabled to true or false (false by default). 
   */
  UserPane.editEnabled = function(bool) {
    if (bool) {
      pane.addClass('edit-enabled');
    } else {
      pane.removeClass('edit-enabled');
    }
  
    return UserPane;
  };

  return UserPane;
}(Fleet.Frame.UserPane || {}, Fleet, jQuery));
