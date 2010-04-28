/**
 * Fleet.Frame.UserEditPane
 *
 * User Edit Pane
 */
var Fleet = Fleet || {};
Fleet.Frame = Fleet.Frame || {};
Fleet.Frame.UserEditPane = (function(UserEditPane, Fleet, $) {
  var pane,
      container,
      init = false;

  /**
    * init()
    *
    * Crate and prepare the User Edit pane.
    */
  UserEditPane.init = function() {
    if (init) {
      return UserEditPane;
    }

    // Create the user edit pane
    $('#frame').append('<div id="user_edit_pane"><div class="content"></div></div>');

    // store a reference to the pane
    pane = $('#user_edit_pane');

    // a reference to the content area
    container = pane.children('.content');

    init = true;
    return UserEditPane;
  };

  /**
    * initPane()
    * initPane(html)
    *
    * prepare event handlers and dom manipulation.. load html if provided
    */
  UserEditPane.initPane = function(html) {
    if (typeof(html) != 'undefined') {
      container.html(html);
    }

    return UserEditPane;
  };

  /**
    * submit(options)
    *
    * submit the form.
    */
  UserEditPane.submit = function(options) {
    pane.find('form:first').ajaxSubmit(options);
    return UserEditPane;
  };

  /**
    * parentGroup(id)
    *
    * Set the parent group id in the user form.
    */
  UserEditPane.parentGroup = function(id) {
    if (id == '0') {
      pane.find('input[name=user[device_group_id]]').val('');
    } else {
      pane.find('input[name=user[device_group_id]]').val(id);
    }

    return UserEditPane;
  };

  /**
    * open()
    *
    * Open the user edit pane.
    */
  UserEditPane.open = function() {
    pane.show();
    
    return UserEditPane;
  };

  /** close()
    *
    * Close the user edit pane.
    */
  UserEditPane.close = function() {
    pane.hide();
    return UserEditPane;
  }; 

  return UserEditPane;
}(Fleet.Frame.UserEditPane || {}, Fleet, jQuery));
