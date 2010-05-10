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
    $('#frame').append('<div id="group_pane" class="hierarchy"><ol></ol></div>');
    
    // Store a permanent reference to the pane
    pane = $('#group_pane');
    
    // Our list of groups
    list = pane.children('ol');
    
    // Allow user to toggle collapsible groups open and closed
    $('#group_pane div.group span.indent, #group_pane div.group span.collapsible').live('click', function() {
      var self = $(this).parent().children('span.collapsible');
      var _li = self.closest('li')
      if (_li.children('ol').toggle().css('display') == 'none') {
        self.addClass('closed');
      } else {
        self.removeClass('closed');
      }
      
      return false;
    });
    
    // Toggle groups on and off when clicked
    $('#group_pane span.checkbox, #group_pane span.name').live('click', function() {
      var row = $(this).closest('div.row');

      // flip the initial row's value
      row.toggleClass('active');

      // if it is a group, set all children similarly.
      row.siblings('ol').find('div.row').toggleClass('active', row.hasClass('active'));
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
  
  /**
   * selected()
   *
   * Return an array containing the list of selected group ids.
   *
   * selected(array)
   *
   * Select the groups with ids specified in the given array.
   */
  GroupPane.selected = function(arr) {
    var idx, num, id,
        active = list.find('div.active');
    
    if (arr) {
      active.removeClass('active');
      
      for(idx = 0, num = arr.length; idx < num; idx++) {
        $('#device_group_' + arr[idx]).addClass('active')
          .siblings('ol').find('div.row').addClass('active');
      }
    } else {
      arr = [];
      
      for(idx = 0, num = active.length; idx < num; idx++) {
        id = active[idx].id;
        
        arr.push(id.substring(id.lastIndexOf('_') + 1));
      }
    }
    
    return arr;
  };
  
  /**
   * select()
   * select(array)
   *
   * The select() function is an alias for selected().
   */
  GroupPane.select = GroupPane.selected;
  
  return GroupPane;
}(Fleet.Frame.GroupPane || {}, Fleet, jQuery));
