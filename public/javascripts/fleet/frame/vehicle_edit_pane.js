/**
 * Fleet.Frame.VehicleEditPane
 *
 * Represents the vehicle edit pane, accessible from the dashboard.
 */
var Fleet = Fleet || {};
Fleet.Frame = Fleet.Frame || {};
Fleet.Frame.VehicleEditPane = (function(VehicleEditPane, Fleet, $) {
  var pane,
      container,
      init = false;
  
  /**
   * init()
   *
   * Create and prepare the Vehicle Edit pane.
   */
  VehicleEditPane.init = function() {
    if (init) {
      return VehicleEditPane;
    }
    
    // Create the vehicle edit pane
    $('#frame').append('<div id="vehicle_edit_pane"><div class="content"></div></div>');
    
    // Store a permanent reference to the pane
    pane = $('#vehicle_edit_pane');
    
    // A reference to the content area
    container = pane.children('.content');
    
    init = true;
    return VehicleEditPane;
  };
   
  /**
   * initPane()
   * initPane(html)
   *
   * Prepare any necessary event handlers or DOM manipulation. If provided,
   * load the given HTML into the pane first.
   */
  VehicleEditPane.initPane = function(html) {
    if (typeof(html) != 'undefined') {
      container.html(html);
    }

    return VehicleEditPane;
  };
  
  /**
   * submit(options)
   *
   * Used by the controller to submit the edit pane form. The options
   * passed in will be forwarded to the ajaxSubmit method.
   */
  VehicleEditPane.submit = function(options) {
    pane.find('form:first').ajaxSubmit(options);
    
    return VehicleEditPane;
  };
  
  /**
   * open()
   *
   * Open the vehicle edit pane.
   */
  VehicleEditPane.open = function() {
    pane.show();
    
    return VehicleEditPane;
  };
  
  /**
   * close()
   *
   * Close the vehicle edit pane.
   */
  VehicleEditPane.close = function() {
    pane.hide();
    
    return VehicleEditPane;
  };

  return VehicleEditPane;
}(Fleet.Frame.VehicleEditPane || {}, Fleet, jQuery));
