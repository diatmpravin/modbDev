/**
 * Fleet.Frame.DashboardPane
 *
 * Represents the dashboard pane with its report card view.
 *
 */
var Fleet = Fleet || {};
Fleet.Frame = Fleet.Frame || {};
Fleet.Frame.DashboardPane = (function(DashboardPane, Fleet, $) {
  var width = 280,
      pane,
      list,
      new_chooser,
      init = false;
  
  /**
   * init()
   *
   * Create and prepare the Dashboard pane.
   */
  DashboardPane.init = function() {
    if (init) {
      return DashboardPane;
    }
    
    // Create the dashboard pane
    $('#frame').append('<div id="dashboard_pane" class="hierarchy edit-enabled"><ol></ol></div>');
    
    // Store a permanent reference to the pane
    pane = $('#dashboard_pane');
    
    // Our list of vehicles and groups
    list = pane.children('ol');
    
    // Create our new chooser widget
    new_chooser = $('<div id="new_chooser"><ul><li>New Vehicle</li><li>New Group</li></ul></div>').appendTo('body');
    
    // Allow user to toggle collapsible groups open and closed
    $('#dashboard_pane div.group span.indent, #dashboard div.group span.collapsible').live('click', function() {
      var self = $(this).parent().children('span.collapsible');
      var _li = self.closest('li')
      if (_li.children('ol').toggle().css('display') == 'none') {
        self.addClass('closed');
      } else {
        self.removeClass('closed');
      }
      
      return false;
    });
    
    $('#dashboard_pane a.edit').live('click', Fleet.DashboardController.edit);
    $('#dashboard_pane a.delete').live('click', Fleet.DashboardController.remove);
    
    $('#dashboard_pane span.new').live('mouseenter', function() {
      new_chooser.appendTo(this).show();
    }).live('mouseleave', function() {
      new_chooser.hide();
    });
    
    /* Commented out for now -- don't need checkboxes?
    // Toggle groups and vehicles on and off when clicked
    $('span.checkbox,span.name').live('click', function() {
      var row = $(this).closest('div.row');

      // flip the initial row's value
      row.toggleClass('active');

      // if it is a group, set all children similarly.
      row.siblings('ol').find('div.row').toggleClass('active', row.hasClass('active'));
    });*/
  
    init = true;
    return DashboardPane;
  };
  
  /**
   * initPane(html)
   * initPane(html, id)
   *
   * Take the given list of groups & vehicles and populate the dashboard. If
   * provided, the html will be inserted at the given id.
   */
  DashboardPane.initPane = function(html, id) {
    var root = $('#' + id);
    
    // Needs some work. Basically, we're trying to replace only the portion of
    // the tree that was sent us, or the entire tree if it's the first time.
    if (root.length > 0) {
      root.closest('li').replaceWith(html);
      root = $('#' + id).closest('li');
    } else {
      list.html(html);
      root = list;
    }
    
    // Hide collapsible arrows for empty groups
    root.find('li:not(:has(li)) span.collapsible').removeClass('collapsible').addClass('empty');

    // Allow user to drag groups and vehicles around
    root.find('div.row').draggable({
      helper: 'clone',
      handle: 'div.listing',
      opacity: 0.8,
      distance: 8
    });
    
    // Allow user to drop groups onto other groups
    root.find('div.group').droppable({
      hoverClass: 'drop-hover',
      greedy: true,
      drop: function(event, ui) {
        Fleet.DashboardController.move(ui.draggable, $(this));
      }
    });
    
    return DashboardPane;
  };
  
  /**
   * open()
   * open(callback)
   *
   * Open the vehicle pane.  If provided, the callback will be called
   * after the pane is opened.
   */
  DashboardPane.open = function(callback) {
    pane.animate({width: '100%'}, {
      duration: 400,
      complete: function() {
        // Free the report card width so it resizes naturally
        list.css('width', 'auto');
        
        if ($.isFunction(callback)) {
          callback();
        }
      }
    });
    
    return DashboardPane;
  };
  
  /**
   * close()
   * close(callback)
   *
   * Close the vehicle pane. If provided, the callback will be called
   * after the pane is closed.
   */
  DashboardPane.close = function(callback) {
    // Fix the report card width so it doesn't break while sliding
    list.css('width', function() { return $(this).width() + 'px'; });
    
    if ($.isFunction(callback)) {
      pane.animate({width: 0}, {
        duration: 400,
        complete: callback
      });
    } else {
      pane.animate({width: 0}, {duration: 400});
    }
    
    return DashboardPane;
  };
  
  /**
   * width()
   *
   * Return the current width of the dashboard pane.
   */
  DashboardPane.width = function() {
    return pane.width();
  };
  
  return DashboardPane;
}(Fleet.Frame.DashboardPane || {}, Fleet, jQuery));
