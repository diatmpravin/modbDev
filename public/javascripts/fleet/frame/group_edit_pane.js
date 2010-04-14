/**
 * Fleet.Frame.GroupEditPane
 *
 * Represents the group edit pane, accessible from the dashboard.
 */
var Fleet = Fleet || {};
Fleet.Frame = Fleet.Frame || {};
Fleet.Frame.GroupEditPane = (function(GroupEditPane, Fleet, $) {
  var pane,
      container,
      init = false;
  
  /**
   * init()
   *
   * Create and prepare the Group Edit pane.
   */
  GroupEditPane.init = function() {
    if (init) {
      return GroupEditPane;
    }
    
    // Create the group edit pane
    $('#frame').append('<div id="group_edit_pane"><div class="content"></div></div>');
    
    // Store a permanent reference to the pane
    pane = $('#group_edit_pane');
    
    // A reference to the content area
    container = pane.children('.content');
    
    init = true;
    return GroupEditPane;
  };
   
  /**
   * initPane()
   * initPane(html)
   *
   * Prepare for any necessary event handlers or DOM manipulation. If provided,
   * load the given HTML into the pane first.
   */
  GroupEditPane.initPane = function(html) {
    if (typeof(html) != 'undefined') {
      container.html(html);
    }
    
    // Call our private function for each slider
    container.find('.slider').each(initSlider);
    
    // Call our private function for each time slider
    container.find('.time-slider').each(initTimeSlider);
    
    return GroupEditPane;
  };
  
  /**
   * submit(options)
   *
   * Used by the controller to submit the edit pane form. The options
   * passed in will be forwarded to the ajaxSubmit method.
   */
  GroupEditPane.submit = function(options) {
    pane.find('form:first').ajaxSubmit(options);
    
    return GroupEditPane;
  };
  
  /**
   * open()
   *
   * Open the group edit pane.
   */
  GroupEditPane.open = function() {
    pane.show();
    
    return GroupEditPane;
  };
  
  /**
   * close()
   *
   * Close the group edit pane.
   */
  GroupEditPane.close = function() {
    pane.hide();
    
    return GroupEditPane;
  };

  /* Private Functions */
  
  // Most of this stuff was taken from Jason's implementation of group sliders... Maybe it's me,
  // but it seems kind of complicated?
  
  function initSlider(idx, slider) {
    var input_fail = $(slider).find("input.fail"),
        input_pass = $(slider).find("input.pass"),
        disp_fail = $(slider).siblings("span.fail"),
        disp_pass = $(slider).siblings("span.pass");
        
    setView($(slider), input_pass.val(), input_fail.val(), true);

    $(slider).slider({
      range: true,
      min: 0,
      max: 50,
      values: initialValues(slider, input_pass.val(), input_fail.val()),
      slide: function(event, ui) {
        var pass = ui.values[0], fail = ui.values[1];

        setView(slider, pass, fail);
        setValues(slider, pass, fail);
      }
    });
  }

  // Source: http://stackoverflow.com/questions/2279784/jquery-ui-slider-for-time
  function initTimeSlider(idx, slider) {
    var input_fail = $(slider).find("input.fail"),
        input_pass = $(slider).find("input.pass"),

    slider = $(slider);

    setView(slider, 
      convertToTime(input_pass.val()), 
      convertToTime(input_fail.val()), true);

    slider.slider({
      range: true,
      min: 0,
      max: 86100,
      step: 300,
      values: initialValues(slider, input_pass.val(), input_fail.val()),
      slide: function(e, ui) {
        var pass = ui.values[0], fail = ui.values[1];

        setView(slider, convertToTime(pass), convertToTime(fail));
        setValues(slider, pass, fail);
      }
    });
  }
  
  function initialValues(slider, pass, fail) {
    var tmp;
    slider = $(slider);

    if(slider.hasClass("reversed")) {
      tmp = fail;
      fail = pass;
      pass = tmp; 
    }
    
    return [pass, fail];
  }
  
  function setView(slider, pass, fail, ignoreReverse) {
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
  
  function setValues(slider, pass, fail) {
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
  
  function convertToTime(value) {
    var hours = Math.floor(value / 3600),
        minutes = (value - (hours * 3600))/60;

    if(minutes < 10) minutes = '0' + minutes;

    return hours + ':' + minutes;
  }
  
  return GroupEditPane;
}(Fleet.Frame.GroupEditPane || {}, Fleet, jQuery));
