/**
 * Fleet.Frame.GroupEditPane
 *
 * Represents the group edit pane, accessible from the dashboard.
 */
var Fleet = Fleet || {};
Fleet.Frame = Fleet.Frame || {};
Fleet.Frame.GroupEditPane = (function(GroupEditPane, Fleet, $) {
  var pane,
      container,
      init = false;
  
  /**
   * init()
   *
   * Create and prepare the Group Edit pane.
   */
  GroupEditPane.init = function() {
    if (init) {
      return GroupEditPane;
    }
    
    // Create the group edit pane
    $('#frame').append('<div id="group_edit_pane"><div class="content"></div></div>');
    
    // Store a permanent reference to the pane
    pane = $('#group_edit_pane');
    
    // A reference to the content area
    container = pane.children('.content');
    
    init = true;
    return GroupEditPane;
  };
   
  /**
   * initPane()
   * initPane(html)
   *
   * Prepare any necessary event handlers or DOM manipulation. If provided,
   * load the given HTML into the pane first.
   */
  GroupEditPane.initPane = function(html) {
    if (typeof(html) != 'undefined') {
      container.html(html);
    }

    return GroupEditPane;
  };
  
  /**
   * open()
   *
   * Open the group edit pane.
   */
  GroupEditPane.open = function() {
    pane.show();
    
    return GroupEditPane;
  };
  
  /**
   * close()
   *
   * Close the group edit pane.
   */
  GroupEditPane.close = function() {
    pane.hide();
    
    return GroupEditPane;
  };

  return GroupEditPane;
}(Fleet.Frame.GroupEditPane || {}, Fleet, jQuery));
