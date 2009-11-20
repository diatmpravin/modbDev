/**
 * Filter.js
 * Hooks and handling of the Filter form
 */
Filter = {

  init: function() {
    // q("#query").focus(Filter.showDetails);
    //q("#filterDetails").css("width", q("#filter").width() - 1);

    q("form", "#filter")
      .submit(Filter.submitQuery)
      .find("#filter_clear")
      .click(Filter.clearQuery);
  }
  ,
  submitQuery: function() {
    q(this).ajaxSubmit({
      beforeSubmit: function() { },
      complete: function() { location.reload(); }
    });

    return false;
  }
  ,
  clearQuery: function() {
    q(this).parents("form").attr("method", "DELETE").ajaxSubmit({
      beforeSubmit: function() { q("#query").val("") },
      complete: function() { location.reload(); }
    });
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

