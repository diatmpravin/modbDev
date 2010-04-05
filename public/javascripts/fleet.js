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
  };
  
  return Fleet;
}(Fleet || {}, jQuery));
