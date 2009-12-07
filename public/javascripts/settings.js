/**
 * Settings
 *
 * Constants and functions used on all Settings pages.
 *
 * Remember: jQuery = q() or $q()!
 */
Settings = {
  init: function() {
    q('#settings').corners('transparent');
  }
}

/* Initializer */
jQuery(function() {
  Settings.init();
});
