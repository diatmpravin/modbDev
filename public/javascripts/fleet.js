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
  Fleet.Controller = null;
  
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
      
      if (Fleet.Controller && Fleet.Controller.teardown) {
        Fleet.Controller.teardown();
      }
      
      Fleet.Controller = o;
      
      if (Fleet.Controller && Fleet.Controller.setup) {
        Fleet.Controller.init();
        Fleet.Controller.setup();
      }
      
      Fleet.loading(false);
    }
    
    return Fleet.Controller;
  };
  
  return Fleet;
}(Fleet || {}, jQuery));
