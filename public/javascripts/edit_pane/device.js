/**
 * Edit Pane - Device
 */
if (typeof EditPane == 'undefined') { EditPane = {}; }
if (typeof EditPane.Device == 'undefined') { EditPane.Device = {}; }

EditPane.Device = {
  /**
   * Setup global page objects (dialog boxes, etc.).
   */
  init: function() {
    q('#moveDevice').dialog({
      modal: true,
      autoOpen: false,
      resizable: false,
      width: 300,
      buttons: {
        'Move': EditPane.Device.move,
        'Cancel': function() { q(this).dialog('close'); }
      }
    });
    
    q('#removeDevice').dialog({
      modal: true,
      autoOpen: false,
      resizable: false,
      width: 450,
      buttons: {
        'Remove': EditPane.Device.remove,
        'Cancel': function() { q(this).dialog('close'); }
      }
    });
  },
  
  /**
   * Prepare any fancy sliders, buttons, and events for the edit pane. If
   * provided, load up the pane first with the given HTML.
   */
  initPane: function(html) {
    if (typeof(html) != 'undefined') {
      q('#edit_pane .edit').html(html);
    }
    
    // Pretty & clickable buttons
    q('#edit_pane .buttons').find('a, input').button();
    q('#edit_pane .buttons .cancel').click(EditPane.Device.cancel);
    q('#edit_pane .buttons .save').click(EditPane.Device.save);
    
    // Lock/unlock profile settings
    q('#edit_pane select.profile').change(EditPane.Device.setProfile);

    // Lock/unlock VIN number
    q('#edit_pane input.vinNumber').change(EditPane.Device.updateVIN).change();
    
    // Setup device profile stuff
    DeviceProfile.Form.initPane('#edit_pane');
    
    // Alert Recipient
    AlertRecipients.prepare('#edit_pane');

    // Tags
    Tags.prepare('#edit_pane');
    
    return q('#edit_pane .edit');
  },
  
  /**
   * Show the edit form for a new device.
   */
  newDevice: function() {
    EditPane.clear().title('Create Vehicle');
    DataPane.close();
    
    q.get(q(this).attr('href'), function(html) {
      EditPane.Device.initPane(html);
      EditPane.show();
    });
    
    return false;
  },
  
  /**
   * Show the edit form for the selected device.
   */
  edit: function() {
    EditPane.clear().title('Edit Vehicle');
    DataPane.close();
    
    q.get(q(this).attr('href'), function(html) {
      q('#edit_pane').find('.loading').hide();
      
      EditPane.Device.initPane(html).show();
    });
    
    return false;
  },
  
  /**
   * Save the device and close the device edit form.
   */
  save: function() {
    var self = q(this);
    
    q('#edit_pane form').ajaxSubmit({
      dataType: 'json',
      beforeSubmit: function() { },
      success: function(json) {
        if (json.status == 'success') {
          DataPane.update()
          
          //self.dialogLoader(false);
          
          DataPane.open();
          EditPane.title();
        } else {
          EditPane.Device.initPane(json.html);
        }
      }
    });
    
    return false;
  },
  
  /**
   * Close the device edit form without saving.
   */
  cancel: function() {
    DataPane.open();
    EditPane.title();
                    
    return false;
  },
  
  /**
   * Show the move confirmation dialog box.
   */
  confirmMove: function(dragDevice, dropGroup) {
    var dragId = dragDevice.attr('id').match(/.+_(\d*)/)[1]
    var dropId = dropGroup.attr('id').match(/.+_(\d*)/)[1]
    
    // Store references to the "dragged" and "dropped" groups, and update the
    // the move form so it can submit the correct ids.
    q('#moveDevice').data('dragDevice', dragDevice)
      .data('dropGroup', dropGroup)
      .find('form').attr('action', '/devices/' + dragId)
      .find('input.group_id').val(dropId);
    
    // Insert the names of the two groups in some placeholder spans.
    q('#moveDevice span.from').text(dragDevice.find('span.name').text());
    q('#moveDevice span.to').text(dropGroup.find('span.name').text());
    
    q('#moveDevice').errors().dialog('open');
    
    return false;
  },
  
  /**
   * Move a group from one position to another.
   */
  move: function() {
    var self = q(this);
    
    self.find('form').ajaxSubmit({
      dataType: 'json',
      beforeSubmit: function() { self.dialogLoader(true); },
      success: function(json) {
        self.dialogLoader(false);
        
        if (json.status == 'success') {
          self.dialog('close');
          
          //TODO indicate reload somehow?
          DataPane.update();
        } else {
          self.errors(json.error);
        }
      }
    });
    
    return false;
  },
  
  /**
   * Show the remove confirmation dialog box.
   */
  confirmRemove: function() {
    q('#removeDevice').find('form').attr('action', this.href).end()
                     .dialog('open');
    
    return false;
  },
  
  /**
   * Remove the selected device from the list.
   */
  remove: function() {
    var self = q(this);
    
    self.find('form').ajaxSubmit({
      dataType: 'json',
      beforeSubmit: function() { self.dialogLoader(true); },
      success: function(json) {
        self.dialogLoader(false);
        
        if (json.status == 'success') {
          self.dialog('close');
          
          DataPane.update()
        } else {
          self.errors(json.error);
        }
      }
    });
    
    return false;
  },
  
  /**
   * Show or hide the Lock VIN field based on the VIN text field.
   */
  updateVIN: function() {
    if(q(this).val() == '') {
      q('.lockVIN').hide().find('input').attr('checked', false);
    } else {
      q('.lockVIN').show();
    }
  },
  
  /**
   * Lock the profile settings area and fill in the settings with an ajax
   * call. If the user has removed the profile, unlock the profile settings
   * area instead.
   */
  setProfile: function() {
    var self = q(this);
    var profile = self.val();
    
    if (profile == '') {
      q('.profileSettings').removeClass('profileLocked')
        .find('input,select').attr('disabled', false);
    } else {
      q('.profileSettings').addClass('profileLocked')
        .find('input,select').attr('disabled', true);
        
      self.siblings('.loading').show();
      q.getJSON('/device_profiles/' + profile, function(json) {
        // This is more verbose than I want it to be, but I need to avoid
        // screwing up Rails' "checkbox+hidden-field" method of creating
        // checkboxes.
        for(var f in json.device_profile) {
          var field = q('.profileSettings input[type=checkbox][name$=\[' + f + '\]]');
          if (field.length > 0) {
            field.attr('checked', json.device_profile[f]);
          } else {
            field = q('.profileSettings input[name$=\[' + f + '\]],.profileSettings select[name$=\[' + f + '\]]');
            field.val(json.device_profile[f]);
          }
        }
        
        q('.profileSettings').find('input[type=checkbox]').click();
        self.siblings('.loading').hide();
      });
    }
  }
};

/* Initialize */
jQuery(EditPane.Device.init);
