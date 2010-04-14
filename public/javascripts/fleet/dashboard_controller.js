/**
 * Fleet.DashboardController
 */
var Fleet = Fleet || {};
Fleet.DashboardController = (function(DashboardController, DashboardPane, VehicleEditPane, GroupEditPane, Header, Frame, $) {
  var confirmMoveVehicleDialog,
      confirmMoveGroupDialog,
      confirmRemoveVehicleDialog,
      confirmRemoveGroupDialog,
      init = false;
  
  /* Dashboard Tab */
  DashboardController.tab = 'dashboard';
  
  /**
   * init()
   */
  DashboardController.init = function() {
    if (init) {
      return DashboardController;
    }
    
    // Side note: both "Move" dialogs and both "Remove" dialogs could be merged into one dialog box
    // each, with the title and text changed depending on whether the user clicks vehicle or group.
    // Someone should either do that, or remove this comment.
    
    // Our confirm Move Vehicle dialog box
    confirmMoveVehicleDialog = $('<div class="dialog" title="Move Vehicle?">Are you sure you want to move this vehicle into the <span class="dropGroup"></span> group?</div>').appendTo('body');
    confirmMoveVehicleDialog.dialog({
      modal: true,
      autoOpen: false,
      resizable: false,
      width: 300,
      buttons: {
        'Move': DashboardController.confirmedMove,
        'Cancel': function() { $(this).dialog('close'); }
      }
    });
    
    // Our confirm Move Group dialog box
    confirmMoveGroupDialog = $('<div class="dialog" title="Move Group?">Are you sure you want to move this group into the <span class="dropGroup"></span> group?</div>').appendTo('body');
    confirmMoveGroupDialog.dialog({
      modal: true,
      autoOpen: false,
      resizable: false,
      width: 300,
      buttons: {
        'Move': DashboardController.confirmedMove,
        'Cancel': function() { $(this).dialog('close'); }
      }
    });
    
    // Our confirm Remove Vehicle dialog box
    confirmRemoveVehicleDialog = $('<div class="dialog" title="Remove Vehicle?">Are you sure you want to remove this vehicle?</div>').appendTo('body');
    confirmRemoveVehicleDialog.dialog({
      modal: true,
      autoOpen: false,
      resizable: false,
      width: 300,
      buttons: {
        'Remove': DashboardController.confirmedRemove,
        'Cancel': function() { $(this).dialog('close'); }
      }
    });
    
    // Our confirm Remove Group dialog box
    confirmRemoveGroupDialog = $('<div class="dialog" title="Remove Group?">Are you sure you want to remove this group?</div>').appendTo('body');
    confirmRemoveGroupDialog.dialog({
      modal: true,
      autoOpen: false,
      resizable: false,
      width: 300,
      buttons: {
        'Remove': DashboardController.confirmedRemove,
        'Cancel': function() { $(this).dialog('close'); }
      }
    });
    
    // Define the big messy dashboard header
    Header.init().define('dashboard',
      '<span class="title">Dashboard</span>' +
      '<div class="dashboard_data">' +
      '<span class="first_start"><span>Start Time</span></span>' +
      '<span class="last_stop"><span>End Time</span></span>' +
      '<span class="operating_time"><span>Operating Time</span></span>' + 
      '<span class="miles_driven"><span>Miles Driven</span></span>' +
      '<span class="average_mpg"><span>Average MPG</span></span>' +
      '<span class="speed_events"><span>Speed Events</span></span>' +
      '<span class="geofence_events"><span>Geofence Events</span></span>' +
      '<span class="idle_events"><span>Idle Events</span></span>' +
      '<span class="aggressive_events"><span>Aggressive Events</span></span>' +
      '<span class="after_hours_events"><span>After Hours Events</span></span>' +
      '</div>');
    
    init = true;
    return DashboardController;
  };
  
  /**
   * setup()
   *
   * Prepare all of our panes and setup the vehicle list view.
   */
  DashboardController.setup = function() {
    DashboardPane.init().open();
    VehicleEditPane.init().close();
    GroupEditPane.init().close();
    
    Header.init().open('dashboard');
    
    DashboardController.refresh();
  };
  
  /**
   * teardown()
   *
   * Hide all of our panes and throw away any unnecessary resources.
   */
  DashboardController.teardown = function() {
    DashboardPane.close().initPane('');
    Header.standard('');
    
    vehicles = null;
    lookup = null;
  };
  
  /**
   * refresh()
   *
   * Load all vehicles from the server and populate them. This call loads actual
   * vehicle data (as opposed to a "hierarchy" html view).
   */
  DashboardController.refresh = function() {
    loading(true);
    
    $.getJSON('/dashboard.json', {range_type: 5}, function(json) {
      loading(false);
      
      DashboardPane.initPane(json.html, json.id);
    });
    
    /*
    
  // what range type?
  rt = q('#range_type').val();

  // get json for the report card tree
  q.getJSON('/report_card', { range_type: rt }, function(json) {
  */
    return DashboardController;
  };
  
  /**
   * edit()
   *
   * Show the edit form for the selected vehicle or group.
   */
  DashboardController.edit = function() {
    var activePane, title, row = $(this).closest('div.row');
    
    if (row.hasClass('group')) {
      activePane = GroupEditPane;
      title = 'Edit Group';
    } else {
      activePane = VehicleEditPane;
      title = 'Edit Vehicle';
    }
    
    loading(true);
  
    $.get($(this).attr('href'), function(html) {
      loading(false);
      
      activePane.initPane(html).open();
      DashboardPane.close();
      Header.edit(title, function() {
        DashboardController.save(activePane);
      }, DashboardController.cancel);
    });
    
    return false;
  };
  
  /**
   * save(activePane)
   *
   * Save the group or vehicle currently being edited. The logic is identical
   * in either case, just pass in the active pane (either VehicleEditPane or
   * GroupEditPane).
   */
  DashboardController.save = function(activePane) {
    activePane.submit({
      dataType: 'json',
      beforeSubmit: function() { loading(true); },
      success: function(json) {
        loading(false);
      
        if (json.status == 'success') {
          Header.open('dashboard');
          DashboardPane.open(function() {
            activePane.close();
            DashboardController.refresh();
          });
        } else {
          activePane.initPane(json.html);
        }
      }
    });
    
    return false;
  };
  
  /**
   * cancel()
   *
   * Close the edit form for the current vehicle or group and return to the
   * dashboard view. Doesn't really matter which one the user is editing,
   * we'll close both forms just to be safe.
   */
  DashboardController.cancel = function() {
    DashboardPane.open(function() {
      GroupEditPane.close();
      VehicleEditPane.close();
    });
    
    Header.open('dashboard');
    
    return false;
  };
  
  /**
   * move(from, to)
   * 
   * Show the move confirmation dialog box for the given move. The first argument
   * can be either a vehicle or group row, and the second argument should be
   * a group row.
   */
  DashboardController.move = function(from, to) {
    var dragId = from.attr('id'); dragId = dragId.substring(dragId.lastIndexOf('_') + 1);
    var dropId = to.attr('id'); dropId = dropId.substring(dropId.lastIndexOf('_') + 1);
    var dialog = from.hasClass('group') ? confirmMoveGroupDialog : confirmMoveVehicleDialog;
    
    // Store references to the dragged item and where it is moving
    dialog.data('from', from)
          .data('to', to)
          .find('span.dropGroup').text(to.find('span.name').text() + ' ');
    
    dialog.errors().dialog('open');
    
    return false;
  };
  
  /**
   * confirmedMove()
   *
   * Called after the user confirms the movement of a group or vehicle.
   */
  DashboardController.confirmedMove = function() {
    var self = $(this),
        from = self.data('from'),
        fromId = from.attr('id'),
        to = self.data('to'),
        toId = to.attr('id'),
        controller = from.hasClass('group') ? '/groups/' : '/devices/';
    
    fromId = fromId.substring(fromId.lastIndexOf('_') + 1);
    toId = toId.substring(toId.lastIndexOf('_') + 1);
    
    self.dialog('close');
    loading(true);
    
    if (from.hasClass('group')) {
      // Move a group into another group
      $.ajax({
        url: '/groups/' + fromId,
        data: {'device_group[parent_id]': toId},
        type: 'PUT',
        dataType: 'json',
        success: function(json) {
          loading(false);
          
          if (json.status == 'success') {
            DashboardController.refresh();
          } else {
            self.errors(json.error).dialog('open');
          }
        }
      });
    } else {
      // Move a vehicle into a group
      $.ajax({
        url: '/devices/' + fromId,
        data: {'device[group_id]': toId},
        type: 'PUT',
        dataType: 'json',
        success: function(json) {
          loading(false);
          
          if (json.status == 'success') {
            DashboardController.refresh();
          } else {
            self.errors(json.error).dialog('open');
          }
        }
      });
    }
    
    return false;
  };  
  
  /**
   * remove()
   *
   * Show the remove confirmation dialog box for the given group or vehicle.
   */
  DashboardController.remove = function() {
    var row = $(this).closest('div.row'),
        dialog = row.hasClass('group') ? confirmRemoveGroupDialog : confirmRemoveVehicleDialog;
    
    dialog.data('row', row).errors().dialog('open');
    
    return false;
  };
  
  /**
   * confirmedRemove()
   *
   * Called after the user confirms the removal of a group or vehicle.
   */
  DashboardController.confirmedRemove = function() {
    var self = $(this),
        row = self.data('row'),
        id = row.attr('id');
    
    id = id.substring(id.lastIndexOf('_') + 1);
    
    self.dialog('close');
    loading(true);
    
    if (row.hasClass('group')) {
      // Remove a group
      $.ajax({
        url: '/groups/' + id,
        type: 'DELETE',
        dataType: 'json',
        success: function(json) {
          loading(false);
          
          if (json.status == 'success') {
            DashboardController.refresh();
          } else {
            self.errors(json.error).dialog('open');
          }
        }
      });
    } else {
      // Remove a vehicle
      $.ajax({
        url: '/devices/' + id,
        type: 'DELETE',
        dataType: 'json',
        success: function(json) {
          loading(false);
          
          if (json.status == 'success') {
            DashboardController.refresh();
          } else {
            self.errors(json.error).dialog('open');
          }
        }
      });
    }
    
    return false;
  };
  
  /* Private Functions */
  
  function loading(bool) {
    Frame.loading(bool);
    Header.loading(bool);
  }
  
  return DashboardController;
}(Fleet.DashboardController || {},
  Fleet.Frame.DashboardPane,
  Fleet.Frame.VehicleEditPane,
  Fleet.Frame.GroupEditPane,
  Fleet.Frame.Header,
  Fleet.Frame,
  jQuery));
