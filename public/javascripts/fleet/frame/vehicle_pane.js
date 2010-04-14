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
    $('#frame').append('<div id="vehicle_pane" class="hierarchy"><ol></ol></div>');
    
    // Store a permanent reference to the pane
    pane = $('#vehicle_pane');
    
    // list of vehicles
    list = pane.children('ol');

    // Allow user to toggle collapsible groups open and closed
    $('#vehicle_pane div.group span.indent, #vehicle_pane div.group span.collapsible').live('click', function() {
      var self = $(this).parent().children('span.collapsible');
      var _li = self.closest('li')
      if (_li.children('ol').toggle().css('display') == 'none') {
        self.addClass('closed');
      } else {
        self.removeClass('closed');
      }
      
      return false;
    });
    
    // User can click to pan
    $('#vehicle_pane li div.row').live('click', function(event) {
      Fleet.Controller.focus.call(this);
    });

    init = true;
    return VehiclePane;
  };
  
  /**
   * toggleActive
   *
   *
   */
  VehiclePane.toggleActive = function() {
      var row = $(this).closest('div.row');

      // flip the initial row's value
      row.toggleClass('active');

      // if it is a group, set all children similarly.
      row.siblings('ol').find('div.row').toggleClass('active', row.hasClass('active'));
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
    list.find('li:not(:has(li)) span.collapsible').removeClass('collapsible').addClass('empty');
    
    return VehiclePane;
  };

  /**
   * selectEnabled(bool)
   *
   * Set select-enabled to true or false (false by default). 
   */
  VehiclePane.selectEnabled = function(bool) {
    if (bool) {
      pane.addClass('select-enabled');
    } else {
      pane.removeClass('select-enabled');
    }
  
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
  VehiclePane.close = function(callback) {
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

  /**
   * getSelectionsByClass()
   *
   * Return all the selected/active objects of given class
   *
   * classType: name of css class attached to row
   *
   */
  VehiclePane.getSelectionsByClass = function(classType) {
    var selections = [];

    //if a div is a row and passed in classType
    //and active, then it is selected.
    list.find('div.row.active.' + classType).each (function () {
      id = $(this).attr('id');
      id = id.substring(id.lastIndexOf('_') + 1);
      selections.push(id);
    });

    return selections;
  }

  /**
   * getSelections()
   *
   * Return the selected/active vehicles.
   *
   */
  VehiclePane.getSelections = function() {
    return VehiclePane.getSelectionsByClass('device');
  }
  
  return VehiclePane;
}(Fleet.Frame.VehiclePane || {}, Fleet, jQuery));
