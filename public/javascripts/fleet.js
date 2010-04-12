/**
 *              .<@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@>. 
 *           .<@@@@@@   $$$$$$$$$$$$$$$$$$$$$\^^^^^^/$$$$@@@>. 
 *        .<@@@@@<   .$$$$$'~       '~'$$$$$$$\  /$$$$$$>@@@@@>. 
 *     .<@@@@@<'   o$$$$$$                `'$$$$$$$$$$$$  '>@@@@@>. 
 *  .<@@@@@<'    o$$$$$$oo.    CRAYON FLEET  )$$$$$$$$$$     '>@@@@@>.
 *  '<@@@@@<    o$$$$$$$$$$$.                                 >@@@@@>' 
 *    '<@@@@<  o$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$oooooo...    >@@@@>' 
 *      '@@@@< $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$)>@@@@>' 
 *        '<@@@@$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$@@@@>' 
 *          '<@@@@$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$@@@@>' 
 *            '<@@@@<    .oooo.                    .$$@@@@>' 
 *              '<@@@@oo$$$$$$$o..             ..o$$@@@@>' 
 *                '<@@@@$$$$$$$$$$$$$oooooooo$$$$$@@@@>' 
 *                  '<@@@@'$$$$$$$$$$$$$$$$$$$$$@@@@>' 
 *                    '<@@@@<   ~"SSSSSS"~   >@@@@>' 
 *                      '<@@@@<            >@@@@>' 
 *                        '<@@@@<        >@@@@>' 
 *                          '<@@@@<    >@@@@>' 
 *                            '<@@@@<>@@@@>' 
 *                              '<@@@@@@>' 
 *                                '<@@>' 
 */
var Fleet = (function(Fleet, $) {
  /**
   * Controller is a reference to the currently active controller.
   */
  Fleet.Controller = null;
  
  /**
   * init()
   * init(frameOnly)
   *
   * This function initializes the Fleet framework and starts up the first
   * controller. If provided, the location anchor will determine the controller
   * that starts first (default is Dashboard).
   *
   * If the optional frameOnly argument is true, no controller will be started
   * up and the tabnav links will be left as-is.
   */
  Fleet.init = function(frameOnly) {
    var c, hash;
    
    // Create and init our frame
    if (Fleet.Frame.init()) {
      Fleet.Frame.open().resize();
    }
    
    if (frameOnly) {
      return Fleet;
    }
    
    // Start up an initial controller
    hash = location.href.split('#')[1] || '';
    
    if (hash == Fleet.LandmarkController.tab) {
      c = Fleet.LandmarkController;
    } else if (hash == Fleet.ReportController.tab) {
      c = Fleet.ReportController;
    } else if (hash == Fleet.MapController.tab) {
      c = Fleet.MapController;
    } else {
      c = Fleet.DashboardController;
    }
    
    //$('#navbar a.dashboard').click(function() { Fleet.controller(Fleet.DashboardController); return true; });
    $('#navbar a.mapview').click(function()   { Fleet.controller(Fleet.MapController);       return true; });
    $('#navbar a.reports').click(function()   { Fleet.controller(Fleet.ReportController);    return true; });
    $('#navbar a.landmarks').click(function() { Fleet.controller(Fleet.LandmarkController);  return true; });
    
    Fleet.controller(c);
    
    return Fleet;
  };
  
  /**
   * controller()
   *
   * Return the currently active controller.
   *
   * controller(newController)
   *
   * Switch from the current controller to a new controller. The argument
   * should be an actual controller (such as Fleet.LandmarkController).
   */
  Fleet.controller = function(o) {
    if (o) {
      Fleet.loading(true);
      
      // Tear down old controller, if necessary
      if (Fleet.Controller && Fleet.Controller.teardown) {
        Fleet.Controller.teardown();
      }
      
      Fleet.Controller = o;
      
      // Setup new controller
      if (Fleet.Controller && Fleet.Controller.setup) {
        Fleet.Controller.init();
        Fleet.Controller.setup();
        
        // Handle the navigation bar
        if (Fleet.Controller.tab) {
          $('#navbar a.' + Fleet.Controller.tab).closest('li').addClass('active')
                                                .siblings().removeClass('active');
        } else {
          $('#navbar li').removeClass('active');
        }
      }
      
      Fleet.loading(false);
    }
    
    return Fleet.Controller;
  };
  
  /**
   * loading(boolean)
   *
   * Show or hide a loading panel. Defaults to true.
   */
  Fleet.loading = function(bool) {
    var loadingView = $('#fleet_loading');
    
    if (loadingView.length == 0) {
      loadingView = $('<div id="fleet_loading">Please wait...</div>').appendTo('#content .content');
    }
    
    if (typeof bool == 'undefined') {
      bool = true;
    }
    
    loadingView.toggle(bool);
    loadingView.height($(window).height() - loadingView.offset().top - 1);
    
    return Fleet;
  };
  
  return Fleet;
}(Fleet || {}, jQuery));
