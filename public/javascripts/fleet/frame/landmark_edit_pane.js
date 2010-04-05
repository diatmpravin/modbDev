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
      content,
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
    $('#frame').append('<div id="landmark_edit_pane"><div class="content"></div></div>');
    
    // Store a permanent reference to the pane
    pane = $('#landmark_edit_pane');
    
    // A reference to our content
    content = pane.children('.content');
    
    init = true;
    return LandmarkEditPane;
  };
  
  /**
   * initPane(html)
   *
   * Replace the pane's content with the given HTML.
   */
  LandmarkEditPane.initPane = function(html) {
    if (html) {
      content.html(html);
    }
    
    return LandmarkEditPane;
  };
  
  /**
   * open()
   *
   * Open the landmark edit pane.
   */
  LandmarkEditPane.open = function() {
    pane.animate({opacity: 1, right: 16}, {duration: 400});
    
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
