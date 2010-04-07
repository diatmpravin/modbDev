/**
 * Fleet.Frame.GroupPane
 *
 * A group-only list pane intended for the left side of the frame.
 */
var Fleet = Fleet || {};
Fleet.Frame = Fleet.Frame || {};
Fleet.Frame.GroupPane = (function(GroupPane, Fleet, $) {
  var width = 280,
      pane,
      list,
      init = false;
  
  /**
   * init()
   *
   * Create and prepare the Group pane.
   */
  GroupPane.init = function() {
    if (init) {
      return GroupPane;
    }
    
    // Create the group pane
    $('#frame').append('<div id="group_pane"><ol></ol></div>');
    
    // Store a permanent reference to the pane
    pane = $('#group_pane');
    
    // Our list of landmarks
    list = pane.children('ol');
    
    // Toggle groups on and off when clicked
    $('#group_pane div.group').live('click', function() {
      $(this).toggleClass('active');
    });
    
    init = true;
    return GroupPane;
  };
  
  /**
   * showGroups(html)
   * showGroups(groups)
   *
   * Take the given list of groups (or a block of HTML) and populate the
   * group list. Clears any existing group HTML.
   */
  GroupPane.showGroups = function(groups) {
    var idx, num, html;
    
    if (typeof(groups) == 'string') {
      list.html(groups);
    } else {
      for(idx = 0, num = groups.length, html = ''; idx < num; idx++) {
        html += '<li id="group_' + groups[idx].id + '">' + groups[idx].name + '</li>';
      }
      
      list.html(html);
    }
    
    return GroupPane;
  };
  
  /**
   * open()
   * open(callback)
   *
   * Open the group pane. If provided, the callback will be called after
   * the pane is open.
   */
  GroupPane.open = function(callback) {
    if ($.isFunction(callback)) {
      pane.animate({width: width}, {
        duration: 400,
        complete: callback
      });
    } else {
      pane.animate({width: width}, {duration: 400});
    }
    
    return GroupPane;
  };
  
  /**
   * close()
   * close(callback)
   *
   * Close the group pane. If provided, the callback will be called after
   * the pane is closed.
   */
  GroupPane.close = function(callback) {
    if ($.isFunction(callback)) {
      pane.animate({width: 0}, {
        duration: 400,
        complete: callback
      });
    } else {
      pane.animate({width: 0}, {duration: 400});
    }
    
    return GroupPane;
  };
  
  /**
   * width()
   *
   * Return the current width of the group pane.
   */
  GroupPane.width = function() {
    return pane.width();
  };
  
  return GroupPane;
}(Fleet.Frame.GroupPane || {}, Fleet, jQuery));
