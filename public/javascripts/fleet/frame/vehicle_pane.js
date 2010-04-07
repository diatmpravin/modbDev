/**
 * Fleet.Frame.VehiclePane
 *
 * Represents the vehicle pane within our resizable frame.
 *
 */
var Fleet = Fleet || {};
Fleet.Frame = Fleet.Frame || {};
Fleet.Frame.VehiclePane = (function(VehiclePane, Fleet, $) {
  var width = 280,
      pane,
      list,
      init = false;
  
  /**
   * init()
   *
   * Create and prepare the Vehicle pane.
   */
  VehiclePane.init = function() {
    if (init) {
      return VehiclePane;
    }
    
    // Create the vehicle pane
    $('#frame').append('<div id="vehicle_pane"><ol></ol></div>');
    
    // Store a permanent reference to the pane
    pane = $('#vehicle_pane');
    
    // list of vehicles
    list = pane.children('ol');

    // Allow user to toggle collapsible groups open and closed
    $('span.indent, span.collapsible').live('click', function() {
      var self = $(this);
      var _li = self.closest('li')
      if (_li.children('ol').toggle().css('display') == 'none') {
        _li.find('span.collapsible').addClass('closed');
      } else {
        _li.find('span.collapsible').removeClass('closed');
      }
    });
    
    // Toggle groups and vehicles on and off when clicked
    $('span.checkbox,span.name').live('click', function() {
      $(this).closest('div.row').toggleClass('active');
    });
  
    init = true;
    return VehiclePane;
  };
  
  /**
   *
   * showVehicles(html)
   *
   * Take the groups & vehicle to populate the list
   * Clears any existing html
   *
   */
  VehiclePane.showVehicles = function(html) {
    list.html(html);

    // Hide collapsible arrows for empty groups
    list.find('li:not(:has(li)) span.collapsible').hide();

    return VehiclePane;
  };

  /**
   * open()
   * open(callback)
   *
   * Open the vehicle pane.  If provided, the callback will be called
   * after the pane is opened.
   */
  VehiclePane.open = function(callback) {
    if ($.isFunction(callback)){
      pane.animate({width: width}, {
        duration: 400,
        complete: callback
      });
    } else {
      pane.animate({width: width}, {duration: 400});
    }
    
    return VehiclePane;
  };
  
  /**
   * close()
   * close(callback)
   *
   * Close the vehicle pane. If provided, the callback will be called
   * after the pane is closed.
   */
  VehiclePane.close = function() {
    if ($.isFunction(callback)) {
      pane.animate({width: 0}, {
        duration: 400,
        complete: callback
      });
    } else {
      pane.animate({width: 0}, {duration: 400});
    }
    
    return VehiclePane;
  };
  
  /**
   * width()
   *
   * Return the current width of the vehicle pane.
   */
  VehiclePane.width = function() {
    return pane.width();
  };
  
  return VehiclePane;
}(Fleet.Frame.VehiclePane || {}, Fleet, jQuery));
