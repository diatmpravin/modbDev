(function($) {
  Vehicles = {
    init: function() {
      $("#uploadForm form").ajaxForm({
        beforeSubmit: function() { 
          $("#uploadForm").hide();
          $("#busy").show();
        },
        complete: function() {
          $("#uploadForm").show();
          $("#busy").hide();
        },
        success: function() { 
        }
      });
    }
  };

  // Live event hookups

  // document-ready initialization
  //$(Vehicles.init);
})(jQuery);
