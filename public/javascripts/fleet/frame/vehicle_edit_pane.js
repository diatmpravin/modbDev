/**
 * Fleet.Frame.VehicleEditPane
 *
 * Represents the vehicle edit pane, accessible from the dashboard.
 */
var Fleet = Fleet || {};
Fleet.Frame = Fleet.Frame || {};
Fleet.Frame.VehicleEditPane = (function(VehicleEditPane, Fleet, $) {
  var pane,
      container,
      init = false;
  
  /**
   * init()
   *
   * Create and prepare the Vehicle Edit pane.
   */
  VehicleEditPane.init = function() {
    if (init) {
      return VehicleEditPane;
    }
    
    // Create the vehicle edit pane
    $('#frame').append('<div id="vehicle_edit_pane"><div class="content"></div></div>');
    
    // Store a permanent reference to the pane
    pane = $('#vehicle_edit_pane');
    
    // A reference to the content area
    container = pane.children('.content');
    
    init = true;
    return VehicleEditPane;
  };
   
  /**
   * initPane()
   * initPane(html)
   *
   * Prepare any necessary event handlers or DOM manipulation. If provided,
   * load the given HTML into the pane first.
   */
  VehicleEditPane.initPane = function(html) {
    if (typeof(html) != 'undefined') {
      container.html(html);
    }
    
    // Lock/unlock profile settings
    container.find('select.profile').change(setProfile);
    
    // Lock/unlock VIN number
    container.find('input.vinNumber').change(updateVIN).change();
    
    // Setup device profile stuff
    DeviceProfile.Form.initPane(pane);
    
    // Alert Recipient
    AlertRecipients.prepare(pane);

    // Tags
    Tags.prepare(pane);
    
    return VehicleEditPane;
  };
  
  /**
   * submit(options)
   *
   * Used by the controller to submit the edit pane form. The options
   * passed in will be forwarded to the ajaxSubmit method.
   */
  VehicleEditPane.submit = function(options) {
    pane.find('form:first').ajaxSubmit(options);
    
    return VehicleEditPane;
  };
  
  /**
   * parentGroup(id)
   *
   * Set the parent group id in the group form. If the id is 0, we were called
   * from root, so blank out the value instead.
   */
  VehicleEditPane.parentGroup = function(id) {
    if (id == '0') {
      pane.find('input[name=device[group_id]]').val('');
    } else {
      pane.find('input[name=device[group_id]]').val(id);
      
    }
    
    return VehicleEditPane;
  };
  
  /**
   * open()
   *
   * Open the vehicle edit pane.
   */
  VehicleEditPane.open = function() {
    pane.show();
    
    return VehicleEditPane;
  };
  
  /**
   * close()
   *
   * Close the vehicle edit pane.
   */
  VehicleEditPane.close = function() {
    pane.hide();
    
    return VehicleEditPane;
  };

  /* Private Functions */
  
  function updateVIN() {
    if($(this).val() == '') {
      $('.lockVIN').hide().find('input').attr('checked', false);
    } else {
      $('.lockVIN').show();
    }
  }
  
  function setProfile() {
    var self = $(this);
    var profile = self.val();
    
    if (profile == '') {
      $('.profileSettings').removeClass('profileLocked')
        .find('input,select').attr('disabled', false);
    } else {
      $('.profileSettings').addClass('profileLocked')
        .find('input,select').attr('disabled', true);
        
      self.siblings('.loading').show();
      $.getJSON('/device_profiles/' + profile, function(json) {
        // This is more verbose than I want it to be, but I need to avoid
        // screwing up Rails' "checkbox+hidden-field" method of creating
        // checkboxes.
        for(var f in json) {
          var field = $('.profileSettings input[type=checkbox][name$=\[' + f + '\]]');
          if (field.length > 0) {
            field.attr('checked', json[f]);
          } else {
            field = $('.profileSettings input[name$=\[' + f + '\]],.profileSettings select[name$=\[' + f + '\]]');
            field.val(json[f]);
          }
        }
        
        $('.profileSettings').find('input[type=checkbox]').click();
        self.siblings('.loading').hide();
      });
    }
  }
  
  return VehicleEditPane;
}(Fleet.Frame.VehicleEditPane || {}, Fleet, jQuery));
