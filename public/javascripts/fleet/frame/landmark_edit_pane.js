/**
 * Fleet.Frame.LandmarkEditPane
 *
 * Represents the overlay pane the user sees while editing a landmark.
 */
var Fleet = Fleet || {};
Fleet.Frame = Fleet.Frame || {};
Fleet.Frame.LandmarkEditPane = (function(LandmarkEditPane, Fleet, $) {
  var width = 200,
      pane,
      init = false;
  
  /**
   * init()
   *
   * Create and prepare the Landmark Edit pane.
   */
  LandmarkEditPane.init = function() {
    if (init) {
      return LandmarkEditPane;
    }
    
    // Create the landmark edit pane
    $('#frame').append('<div id="landmark_edit_pane"></div>');
    
    // Store a permanent reference to the pane
    pane = $('#landmark_edit_pane');
    
    init = true;
    return LandmarkEditPane;
  };
  
  /**
   * initPane()
   *
   * Initialize fancy buttons.
   */
  LandmarkEditPane.initPane = function() {
  };
  
  /**
   * open()
   * open(html)
   *
   * Open the landmark edit pane. Replace the contents with the given HTML, if
   * provided.
   */
  LandmarkEditPane.open = function(html) {
    if (typeof(html) == 'string') {
      pane.html(html).animate({opacity: 1, right: 16}, {duration: 400});
    } else {
      pane.animate({opacity: 1, right: 16}, {duration: 400});
    }
    
    return LandmarkEditPane;
  };
  
  /**
   * close()
   *
   * Close the landmark edit pane.
   */
  LandmarkEditPane.close = function() {
    pane.animate({opacity: 0, right: 0 - (width + 16)}, {duration: 400});
    
    return LandmarkEditPane;
  };
  
  /**
   * submit(options)
   *
   * Used by the controller to submit the edit pane form. The options
   * passed in will be forwarded to the ajaxSubmit method.
   */
  LandmarkEditPane.submit = function(options) {
    pane.find('form:first').ajaxSubmit(options);
    
    return LandmarkEditPane;
  };
  
  return LandmarkEditPane;
}(Fleet.Frame.LandmarkEditPane || {}, Fleet, jQuery));
