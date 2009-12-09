/**
 * Handle form logic on the geofences/edit and geofences/new pages
 */
jQuery(function() {
  q("#map").moshiMap().init();
  q("#sidebar").corners("transparent");

  q("#sidebarContainer").fitWindow(function(newWidth, newHeight) {
    newHeight = Math.max(350, newHeight);
    q('#sidebarContainer').height(newHeight - 32);
    q('#sidebar').height(newHeight - 32 - 16);
    q('#sidebarContent').height(newHeight - 32 - 32);
  });

  // Initialize the geofences view, telling it about the 
  Geofence.view.init(q("#sidebarContainer"));
});
