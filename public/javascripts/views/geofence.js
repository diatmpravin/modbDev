/**
 * View handling of Geofences
 */
if(typeof Geofence == 'undefined') {
  Geofence = {}; 
}

Geofence.view = {
  init: function(sidebar) {
    q("#map").moshiMap().init();

    q("#map").fitWindow(function(newHeight, newWidth) {
      if(sidebar != undefined) {
        newWidth = newWidth - sidebar.width();
      }

      q(this).width(newWidth);
      q(this).height(newHeight);
    });
  }  
};
