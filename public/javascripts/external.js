/**
 * External
 *
 * Constants and functions used on external pages.
 *
 * Remember: jQuery = q() or $q()!
 */
External = {
  init: function() {
    q('.corners').corners('transparent');
    
    q('a.createAccount').click(function() {
      q(this).closest('form').submit();
      return false;
    });
    
    q('a.login').click(function() {
      q(this).closest('form').submit();
      return false;
    });
  }
}

/* Initializer */
jQuery(function() {
  External.init();
});