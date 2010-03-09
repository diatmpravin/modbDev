(function($) {

  Groups = {
    init: function() {
      $.each($(".slider"), Groups.initSlider);
    }
    ,
    /**
     * Initialize the slider w/ values found in 
     * hidden fields in the slider div
     */
    initSlider: function(idx, slider) {
      var input_fail = $(slider).find("input.fail"),
          input_pass = $(slider).find("input.pass"),
          disp_fail = $(slider).siblings("span.fail"),
          disp_pass = $(slider).siblings("span.pass");

      disp_pass.html(input_pass.val());
      disp_fail.html(input_fail.val());

      $(slider).slider({
        range: true,
        min: 0,
        max: 200,
        values: [input_pass.val(), input_fail.val()],
        slide: function(event, ui) {
          input_pass.val(ui.values[0]); 
          disp_pass.html(ui.values[0]);
          input_fail.val(ui.values[1]); 
          disp_fail.html(ui.values[1]); 
        }
      });
    }
  };

  $(Groups.init);
})(jQuery);
