/**
 * Fleet
 * 
 * Contains global methods unique to the Fleet application.
 */
var Fleet = (function(Fleet, $) {
  var loadingView = null;
  
  /**
   * loading(boolean)
   *
   * Show or hide a loading panel. Defaults to true.
   */
  Fleet.loading = function(bool) {
    if (!loadingView) {
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
