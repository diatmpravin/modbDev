/**
 * Frame
 */
Frame = {
  init: function() {
    // When browser window resizes, adjust the size of the report card frame
    q('#frame').fitWindow(function(width, height) {
      // temp hardcoded -2px for top/bottom border and -32px for bottom padding
      q('#frame').height(height - 32 - 2);
    });
    
    // Adjust the padding of certain elements to reflect the scrollbar size
    var scrollbarSize = q('#data_pane').width() - q('#data_pane > ol').width();
    q('.scrollbar-fix').css('padding-right', function() {
      return parseInt(q(this).css('padding-right')) + scrollbarSize;
    });
  }
};

/* Initializer */
jQuery(Frame.init);
