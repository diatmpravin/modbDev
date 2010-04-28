/**
 * Fleet.UserController
 *
 * User Controller
 */
var Fleet = Fleet || {};
Fleet.UserController = (function(UserController, UserPane, UserEditPane, Header, Frame, $) {
  var confirmRemoveDialog,
      confirmMoveUserDialog,
      usersHtml = null;

  /* User Tab */
  UserController.tab = 'users';

  /**
   * init()
   */
  UserController.init = function () {
    //if (init) {
    //  return UserController;
    //}

    // Our confirm remove dialog box
    confirmRemoveDialog = $('<div class="dialog" title="Remove User?">Are you sure you want to remove this user?</div>').appendTo('body');
    confirmRemoveDialog.dialog({
      modal: true,
      autoOpen: false,
      resizable: false,
      width: 300,
      buttons: {
        'Remove': UserController.confirmedRemove,
        'Cancel': function() { $(this).dialog('close'); }
      }
    });

    // confirm Move User dialog box
    confirmMoveUserDialog = $('<div class="dialog" title="Move User?">Are you sure you want to move this user into the <span class="dropGroup"></span> group?</div>').appendTo('body');
    confirmMoveUserDialog.dialog({
      modal: true,
      autoOpen: false,
      resizable: false,
      width: 300,
      buttons: {
        'Move': UserController.confirmedMove,
        'Cancel': function() { $(this).dialog('close'); }
      }
    });

    Header.init().define('users', '<span class="title">Users</span>');
    
  };

  /**
   * setup()
   *
   * Prepare panes
   */
  UserController.setup = function() {
    Header.init().open('users');
    

    UserPane.init().open().editEnabled(true);
    UserEditPane.init().open();

    UserController.refresh();
  };

  /**
   * teardown()
   *
   * Hide panes and throw out stuff
   */
  UserController.teardown = function() {
    UserPane.close().showUsers('');
    UserEditPane.close().initPane('');
    Header.standard('');
    usersHtml = null;
  };

  /**
   * focus()
   *
   */
  UserController.focus = function() {
  };

  /**
   * refresh()
   */
  UserController.refresh = function() {
    // get the users html
    $.get('/users', function(html) {
      usersHtml = html;
      UserPane.showUsers(usersHtml);
    });
  };

  /**
    * new()
    *
    * index -> user creation
    */
  UserController.new = function() {
    var self = $(this),
        row = self.closest('div.row'),
        id = row.attr('id');

    id = id.substring(id.lastIndexOf('_') + 1);

    loading(true);
    //get and set the html on the UserEditPane
    $.get('/users/new', function(html) {
      
      //set the html
      UserEditPane.initPane(html).parentGroup(id).open();
      UserPane.close();

      //change the Header
      Header.edit('New User',
        UserController.save,
        UserController.cancel
      );

      loading(false);
    });

    return false;
  };

  /**
    * cancel()
    *
    * Close the edit form for the current user
    */
  UserController.cancel = function() {
    UserEditPane.close().initPane('');
    UserPane.open();
    Header.open('users');
  };

  /**
    * save()
    *
    * Save the user currently being edited.  
    */
  UserController.save = function() {
    UserEditPane.submit({
      dataType: 'json',
      beforeSubmit: function() {loading(true);},
      success: function(json) {
        loading(false);

        if (json.status == 'success') {
          Header.open('users');
          UserEditPane.close().initPane('');
          UserPane.open();
          UserController.refresh();
        } else {
          UserEditPane.initPane(json.html);
        }
      }
    });

    return false;
  };

  /**
    * edit()
    */
  UserController.edit = function() {
    var id, user;

    id = $(this).closest('div.user').attr('id');
    id = id.substring(id.lastIndexOf('_') + 1);

    //focus should be called?
    //UserController.focus(user);

    //get the edit html and send it into the UserEditPane
    loading(true);
    //get and set the html on the UserEditPane
    $.get('/users/' + id + '/edit', function(html) {
      //set the html and open if necessary?
      UserEditPane.initPane(html).open();
      UserPane.close();

      //change the Header
      Header.edit('Edit User',
        UserController.save,
        UserController.cancel
      );

      loading(false);
    });
  };

  /**
    * remove()
    * 
    * Display a confirmation dialog asking if the user wants to remove the
    * clicked user.
    */
  UserController.remove = function() {
    var id = $(this).closest('div.user').attr('id');
    id = id.substring(id.lastIndexOf('_') + 1);

    confirmRemoveDialog.data('id', id).errors().dialog('open');

    return false;
  };

  /**
    * confirmedRemove()
    *
    * Called after the user confirms the removal of a user.
    */
  UserController.confirmedRemove = function() {
    var id = confirmRemoveDialog.data('id');

    confirmRemoveDialog.dialog('close');
    loading(true);

    $.ajax({
      url: '/users/' + id,
      type: 'DELETE',
      dataType: 'json',
      success: function(json) {
        loading(false);
        if (json.status == 'success') {
          //TODO: Remove user from hierarchy
          $('#user_' + id).slideUp(400, function() {
            $(this).closest('li').remove();
          });
        } else {
          confirmRemoveDialog.errors(json.error).dialog('open');
        }
      }
    });

    return false;
  };

  /**
    * move(from, to)
    *
    * Show the move confirmation dialog box for the move.
    */
  UserController.move = function(from, to) {
    var dragId = from.attr('id'); dragId = dragId.substring(dragId.lastIndexOf('_') + 1);
    var dropId = to.attr('id'); dropId = dropId.substring(dropId.lastIndexOf('_') + 1);
    //var dialog = from.hasClass('group') ? confirmMoveGroupDialog : confirmMoveVehicleDialog;
    var dialog = confirmMoveUserDialog;
    
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
    * called after the user confirms the movement of a user.
    */
  UserController.confirmedMove = function() {
    var self = $(this),
        from = self.data('from'),
        fromId = from.attr('id'),
        to = self.data('to'),
        toId = to.attr('id'),
        controller = from.hasClass('group') ? '/groups/' : '/users/';

    fromId = fromId.substring(fromId.lastIndexOf('_') + 1);
    toId = toId.substring(toId.lastIndexOf('_') + 1);

    self.dialog('close');
    loading(true);
    
    $.ajax({
      url: controller + fromId,
      data: {'user[device_group_id]' : toId},
      type: 'PUT',
      dataType: 'json',
      success: function(json) {
        loading(false);
        
        if (json.status == 'success') {
          UserController.refresh();
        } else {
          self.errors(json.error).dialog('open');
        }
      }
    });

    return false;
  };

  function loading(bool) {
    Frame.loading(bool);
    Header.loading(bool);
  }
  
  return UserController;
}(Fleet.UserController || {},
  Fleet.Frame.UserPane,
  Fleet.Frame.UserEditPane,
  Fleet.Frame.Header,
  Fleet.Frame,
  jQuery));
