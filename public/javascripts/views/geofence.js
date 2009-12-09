/**
 * View handling of Geofences
 */
if(typeof Geofence == 'undefined') {
  Geofence = {}; 
}

Geofence.view = {
  init: function(sidebar) {
    q("#map").moshiMap().init();

    q("#map").fitWindow(function(newWidth, newHeight) {
      if(sidebar != undefined) {
        newWidth = newWidth - sidebar.outerWidth();
      }

      newHeight = Math.max(350, newHeight);

      q(this).width(newWidth);
      q(this).height(newHeight);

      if (MoshiMap.moshiMap) {
        MoshiMap.moshiMap.resizeTo(newWidth, newHeight);
      }
    });
  }  
};
