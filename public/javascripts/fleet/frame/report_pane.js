/**
 * Fleet.Frame.ReportPane
 *
 * Represents the report pane within our resizable frame.
 *
 */
//This needs to have sizes more like map pane than landmark pane.
var Fleet = Fleet || {};
Fleet.Frame = Fleet.Frame || {};
Fleet.Frame.ReportPane = (function(ReportPane, Fleet, $) {
  var pane,
      //width = 280,
      //list,
      //landmarks = null,
      //lookup = null,
      init = false;
  
  /**
   * init()
   *
   * Create and prepare the Report pane.
   */
  ReportPane.init = function() {
    if (init) {
      return ReportPane;
    }
    
    // Create the report pane
    $('#frame').append('<div id="report_pane">report pane goes here</div>');
    
    // Store a permanent reference to the pane
    pane = $('#report_pane');
    
    init = true;
    return ReportPane;
  };
  
  /**
   * open()
   *
   * Open the report pane.
   */
  ReportPane.open = function() {
    pane.show();
    
    return ReportPane;
  };
  
  /**
   * close()
   *
   * Close the report pane.
   */
  ReportPane.close = function() {
    pane.hide();
    
    return ReportPane;
  };
  
  /**
   * width()
   *
   * Return the current width of the report pane.
   */
  //ReportPane.width = function() {
  //  return pane.width();
  //};
  
  return ReportPane;
}(Fleet.Frame.ReportPane || {}, Fleet, jQuery));
