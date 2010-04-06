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
      vehicles = null,
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
    $('#frame').append('<div id="vehicle_pane"></div>');
    
    // Store a permanent reference to the pane
    pane = $('#vehicle_pane');
    
    init = true;
    return VehiclePane;
  };
  
  /**
   * open()
   *
   * Open the vehicle pane.
   */
  VehiclePane.open = function() {
    pane.animate({width: width}, {duration: 400});
    
    return VehiclePane;
  };
  
  /**
   * close()
   *
   * Close the vehicle pane.
   */
  VehiclePane.close = function() {
    pane.animate({width: 0}, {duration: 400});
    
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
