(function($) {

  Groups = {
    init: function() {
      $.each($(".slider"), Groups.initSlider);
      $.each($(".time-slider"), Groups.initTimeSlider);
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

      Groups.setView($(slider), input_pass.val(), input_fail.val(), true);

      $(slider).slider({
        range: true,
        min: 0,
        max: 50,
        values: Groups.initialValues(slider, input_pass.val(), input_fail.val()),
        slide: function(event, ui) {
          var pass = ui.values[0], fail = ui.values[1];

          Groups.setView(slider, pass, fail);
          Groups.setValues(slider, pass, fail);
        }
      });
    }
    ,
    /**
     * Like the above but special handling for sliders that
     * are used to set time values.
     * Got code from: http://stackoverflow.com/questions/2279784/jquery-ui-slider-for-time
     */
    initTimeSlider: function(idx, slider) {
      var input_fail = $(slider).find("input.fail"),
          input_pass = $(slider).find("input.pass"),

      slider = $(slider);

      Groups.setView(slider, 
        Groups.convertToTime(input_pass.val()), 
        Groups.convertToTime(input_fail.val()), true);

      slider.slider({
        range: true,
        min: 0,
        max: 1440,
        step: 15,
        values: Groups.initialValues(slider, input_pass.val(), input_fail.val()),
        slide: function(e, ui) {
          var pass = ui.values[0], fail = ui.values[1];

          Groups.setView(slider, Groups.convertToTime(pass), Groups.convertToTime(fail));
          Groups.setValues(slider, pass, fail);
        }
      });
    }
    ,
    initialValues: function(slider, pass, fail) {
      var tmp;
      slider = $(slider);

      if(slider.hasClass("reversed")) {
        tmp = fail;
        fail = pass;
        pass = tmp; 
      }
      
      return [pass, fail];
    }
    ,
    setView: function(slider, pass, fail, ignoreReverse) {
      var tmp;
      ignoreReverse = ignoreReverse || false;
      slider = $(slider);

      if(slider.hasClass("reversed") && !ignoreReverse) {
        tmp = fail;
        fail = pass;
        pass = tmp; 
      }

      slider.siblings("span.pass").html(pass);
      slider.siblings("span.fail").html(fail);
    }
    ,
    setValues: function(slider, pass, fail) {
      var tmp;
      slider = $(slider);

      if(slider.hasClass("reversed")) {
        tmp = fail;
        fail = pass;
        pass = tmp; 
      }

      slider.find("input.pass").val(pass); 
      slider.find("input.fail").val(fail); 
    }
    ,
    convertToTime: function(value) {
      var hours = Math.floor(value / 60),
          minutes = value - (hours * 60);

      if(minutes == 0) minutes = '0' + minutes;

      return hours + ':' + minutes;
    }
  };

  $(Groups.init);
})(jQuery);
