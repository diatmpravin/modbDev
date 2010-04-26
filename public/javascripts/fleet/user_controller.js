/**
 * Fleet.UserController
 *
 * User Controller
 */
var Fleet = Fleet || {};
Fleet.UserController = (function(UserController, UserPane, UserEditPane, Header, Frame, $) {
  var usersHtml = null;

  /* User Tab */
  UserController.tab = 'users';

  /**
   * init()
   */
  UserController.init = function () {
    Header.init().define('users',
      '<span class="buttons"><button type="button" class="newUser">Add New</button></span><span class="title">Users</span>'
    );
    
  };

  /**
   * setup()
   *
   * Prepare panes
   */
  UserController.setup = function() {
    Header.init().open('users', {
      newUser: UserController.newUser
    });
    

    UserPane.init().open();
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
    * newUser()
    *
    * index -> user creation
    */
  UserController.newUser = function() {
    loading(true);
    //get and set the html on the UserEditPane
    $.get('/users/new', function(html) {
      
      //set the html
      UserEditPane.initPane(html).open();
      //open if necessary?

      //change the Header
      Header.edit('New User',
        UserController.save,
        UserController.cancel
      );

      loading(false);
    });
  };

  /**
    * cancel()
    *
    * Close the edit form for the current user
    */
  UserController.cancel = function() {
    UserEditPane.close();
    Header.open('users', {
      newUser: UserController.newUser
    });
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
          Header.open('users', {
            newUser: UserController.newUser
          });
          UserEditPane.close();
          UserController.refresh();
        } else {
          UserEditPane.initPane(json.html);
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
