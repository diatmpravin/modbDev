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
          row = $(this).parents("tr"),
          parentId = row.attr("id");

      if(!row.data("expanded")) {
        row.find("span").hide();

        var showRows = function() {
          ReportCard.showNested(row);
          row.data("expanded", true);
          row.find(".collapse").show();
          row.addClass("active");
        };

        if(!row.data("filled")) {
          ReportCard.requestSubgroupData(href, row, showRows);
        } else {
          showRows();
        }

      } else {
        ReportCard.hideNested(row);

        row.data("expanded", false);
        row.removeClass("active");
        row.find("span").hide().end().find(".expand").show();
      }

      return false;
    }
    ,
    /**
     * Recursively show groups
     */
    showNested: function(parent) {
      var parentId = parent.attr("id");

      $.each(parent.siblings("tr." + parentId), function(idx, tr) {
        tr = $(tr);

        if(tr.data("expanded") == true) {
          ReportCard.showNested(tr);
        }

        tr.show();
      });
    }
    ,
    /**
     * Recursively hide nested entries
     */
    hideNested: function(parent) {
      var parentId = parent.attr("id");

      $.each(parent.siblings("tr." + parentId + ":visible"), function(idx, tr) {
        tr = $(tr);

        ReportCard.hideNested(tr);

        tr.hide();
      });
    }
    ,
    /**
     * In the case that no sub data has been requested for the
     * selected group, we need to request the data from the server
     */
    requestSubgroupData: function(href, row, callback) {
      $.ajax({
        url: href,
        beforeSend: function() {
          row.find("span").hide();
          row.find(".busy").show();
        },
        complete: function() {
          row.find(".busy").hide();
        },
        success: function(html) {
          row.after(html);
          row.data("filled", true);

          callback();
        }
      });
    }
  };

  // Hooking up live events
  $("a.toggleGroup").live("click", ReportCard.toggleGroup);

  // Document ready
  $(ReportCard.init);
})(jQuery);
