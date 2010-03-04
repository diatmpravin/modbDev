/**
 * Handling for the Report Card page
 */
(function($) {

  ReportCard = {
    init: function() {

    }
    , 
    toggleGroup: function() {
      var href = $(this).attr("href"),
          row = $(this).parents("tr");

      if(!row.data("open")) {
        row.data("open", true);

        $.ajax({
          url: href,
          success: function(html) {
            row.after(html); 
            row.addClass("active");
          }
        });
      } else {
        var i, parentId = row.attr("id");

        // Close every immediate .inner child of this row and no more.
        row.siblings("tr." + parentId).hide().remove();
        row.removeClass("active");
        row.data("open", false);
      }

      return false; 
    }
  };

  // Hooking up live events
  $("a.toggleGroup").live("click", ReportCard.toggleGroup);

  // Document ready
  $(ReportCard.init);
})(jQuery);
