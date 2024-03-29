/**
 * Frame
 */
Frame = {
  resizeHandlers: [],
  
  init: function() {
    // This was added as a "bridge" between OLD and NEW frame implementations.
    q('#frame').show();
    
    // More bridge code: setup Map View and Dashboard buttons.
    q('#navbar .dashboard').click(function() {
      q(this).closest('li').addClass('active')
             .siblings().removeClass('active');
      
      EditPane.title();
      DataPane.open(function() {
        MapPane.close();
      });
      return false;
    });
    
    q('#navbar .mapview').click(function() {
      q(this).closest('li').addClass('active')
             .siblings().removeClass('active');
             
      MapPane.open();
      DataPane.close();
      EditPane.title('');
      return false;
    });
    
    // When browser window resizes, adjust the size of the report card frame
    q('#frame').fitWindow(Frame.resize);
   
    // Adjust the padding of certain elements to reflect the scrollbar size
    var scrollbarSize = q('#data_pane').width() - q('#data_pane > ol').width();
    q('.scrollbar-fix').css('padding-right', function() {
      return parseInt(q(this).css('padding-right')) + scrollbarSize;
    });
  },
  
  /**
   * Call with a function to add a new handler. Resize handlers will be called
   * in the order they were added.
   *
   * Call resize(width, height) to mimic a browser resize.
   */
  resize: function(width, height) {
    if (q.isFunction(width)) {
      // Resize Handler
      Frame.resizeHandlers.push(width); // callback
      
      return true;
    }
    
    // Hardcoded -2px for top/bottom border and -32px for bottom padding
    q('#frame').height(height - 32 - 2);
    
    // Call any resize handler callbacks
    q.each(Frame.resizeHandlers, function(i, handler) {
      handler(width, height);
    });
  }
};

/* Initializer */
jQuery(Frame.init);
