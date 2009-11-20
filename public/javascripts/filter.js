/**
 * Filter.js
 * Hooks and handling of the Filter form
 */
Filter = {

  init: function() {
    // q("#query").focus(Filter.showDetails);

    q("#filterDetails").css("width", q("#filter").width() - 1);
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

