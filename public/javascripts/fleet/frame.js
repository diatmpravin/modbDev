/**
 * Fleet.Frame
 * 
 * Represents the frame that holds the page's data, edit, and map panes. Must be
 * initialized for any other panes to function properly.
 */
var Fleet = Fleet || {};
Fleet.Frame = (function(Frame, $) {
  var resizeHandlers = [],
      frame,
      loader;
  
  /**
   * init()
   *
   * Initialize the frame object and set up needed event handlers.
   */
  Frame.init = function() {
    // Our frame requires zero bottom padding, so make this change now
    $('#content').css('padding-bottom', 0)
                 .children('.content')
                 .css('padding-bottom', 0);
  
    // A reference to the resizable frame
    frame = $('#frame');
    
    // The frame loader
    loader = $('<div id="frame_loader" style="display:none"></div>').appendTo(frame);
  
    // Handle browser resize events
    $(window).resize(Frame.resize).resize();
    
    // Adjust the padding of certain elements to reflect the scrollbar size
    /*var scrollbarSize = q('#data_pane').width() - q('#data_pane > ol').width();
    q('.scrollbar-fix').css('padding-right', function() {
      return parseInt(q(this).css('padding-right')) + scrollbarSize;
    });*/
    
    // Allow user to switch to the Report Card
    /*q('#frame_tabs .data_pane').click(function() {
      q(this).addClass('active')
             .siblings().removeClass('active');
      
      EditPane.title();
      DataPane.open(function() {
        MapPane.close();
      });
    });*/
    
    // Allow user to switch to the Map View
/*    q('#frame_tabs .map_pane').click(function() {
      q(this).addClass('active')
             .siblings().removeClass('active');
      
      MapPane.open();
      DataPane.close();
      EditPane.title('');
    });*/
    
    return Frame;
  };

  /**
   * resize()
   *
   * Respond to a resize event from the browser.
   *
   * resize(function)
   *
   * Add a new resize handler to the frame. This function will be called
   * whenever the frame is resized (and passed the new width and height of
   * the frame).
   */
  Frame.resize = function(f) {
    if ($.isFunction(f)) {
      resizeHandlers.push(f);
      
      return true;
    }
    
    var width = q(window).width();
    var height = q(window).height() - frame.offset().top - 1;
    
    // Hardcoded 32 pixel bottom padding and 2 pixel border
    height -= (32 + 2);
    
    frame.height(height);
    
    $.each(resizeHandlers, function(i, handler) {
      handler(width, height);
    });
    
    return Frame;
  };
  
  /**
   * open()
   * 
   * Call when the frame is fully loaded and ready to be displayed to the user.
   */
  Frame.open = function() {
    frame.show().resize();
    
    return Frame;
  };
  
  /**
   * loading(boolean)
   *
   * Show or hide the loading pane that hovers over ("darkens") the frame
   * content.
   */
  Frame.loading = function(bool) {
    if (bool) {
      loader.css('opacity', 0).show()
            .animate({opacity: 0.3}, {duration: 1500});
    } else {
      loader.stop(true, false).hide();
    }
    
    return Frame;
  };
  
  return Frame;
}(Fleet.Frame || {}, jQuery));
