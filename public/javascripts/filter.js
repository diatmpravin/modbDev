/**
 * Filter.js
 * Hooks and handling of the Filter form
 */
Filter = {

  init: function() {
    q("#filter").focus(Filter.showDetails);
    q("#filter").blur(Filter.hideDetails);

    q("#filterDetails").css("width", q("#filter").css("width"));
  }
  ,
  /**
   * Show the filter details box
   */
  showDetails: function() {
    q("#filterDetails").slideDown('slow'); 
  }
  ,
  /**
   * Hide the filter details box
   */
  hideDetails: function() {
    q("#filterDetails").slideUp('slow'); 
  }

}

jQuery(function() {
  Filter.init();
});

