(function($) {
  Vehicles = {
    init: function() {
      if($("#preview table tr.error").length > 0) {
        $("#uploadForm").hide(); 
        $("#previewError").show();
      }
    }
  };

  // Live event hookups

  // document-ready initialization
  $(Vehicles.init);
})(jQuery);
