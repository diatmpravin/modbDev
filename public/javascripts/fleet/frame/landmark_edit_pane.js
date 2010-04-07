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
    pane.animate({opacity: 0.9, right: 8}, {duration: 400});
    
    return LandmarkEditPane;
  };
  
  /**
   * close()
   *
   * Close the landmark edit pane.
   */
  LandmarkEditPane.close = function() {
    pane.animate({opacity: 0, right: 0 - (width + 8)}, {duration: 400});
    
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
  
  /**
   * location()
   *
   * Return the current lat & long of the landmark being edited.
   *
   * location(lat, lng)
   * location(LatLng)
   *
   * Set the lat/long of the landmark being edited to the given latitude &
   * longitude or MQA LatLng object.
   */
  LandmarkEditPane.location = function(a, b) {
    if (a) {
      if (typeof(a) == 'object') {
        pane.find('form:first .latitude').val(a.lat);
        pane.find('form:first .longitude').val(a.lng);
      } else {
        pane.find('form:first .latitude').val(a);
        pane.find('form:first .longitude').val(b);
      }
    }
    
    return {
      latitude: pane.find('form:first .latitude').val(),
      longitude: pane.find('form:first .longitude').val()
    };
  };
  
  return LandmarkEditPane;
}(Fleet.Frame.LandmarkEditPane || {}, Fleet, jQuery));
