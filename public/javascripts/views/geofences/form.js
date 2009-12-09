/**
 * Handle form logic on the geofences/edit and geofences/new pages
 */
jQuery(function() {
  q("#map").moshiMap().init();
  q("#sidebar").corners("transparent");

  q("#sidebar").fitWindow(function(newHeight, newWidth) {
    newHeight = Math.max(350, newHeight);
    q('#sidebarContainer').height(newHeight - 32);
    q('#sidebar').height(newHeight - 32 - 16);
    q('#sidebarContent').height(newHeight - 32 - 32);
  });
});
