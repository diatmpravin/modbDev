/**
 * Landmarks
 *
 * Constants and functions used on the Landmark Settings page.
 *
 * Remember: jQuery = q() or $q()!
 */
Landmarks = {
  init: function() {
    Landmarks.corners();
    
    q(window).resize(Landmarks.resize);
    Landmarks.resize();
    
  }
  ,
  corners: function() {
    q('#sidebar').corners('transparent');
  }
  ,
  resize: function() {
    var _mapContainer = q('#mapContainer');
    var mapHeight = Math.max(350,
      q(window).height() - _mapContainer.position().top - 1);
    var mapWidth = Math.max(600,
      q(window).width() - q('#sidebarContainer').outerWidth());
    
    _mapContainer.width(mapWidth);
    _mapContainer.height(mapHeight);
    q('#sidebarContainer').height(mapHeight - 32);
    q('#sidebar').height(mapHeight - 32 - 16);
    
    var margin = q('.landmarks').position().top - q('#sidebar').position().top;
    var height = q('#sidebar').outerHeight() - 16;
    var newHeight = height - margin;
    q('.landmarks').css('height', newHeight);
    
    if (MoshiMap.moshiMap) {
      // Introduce an artificial delay to avoid MapQuest resize bugs
      if (Landmarks.resizeTimer) { clearTimeout(Landmarks.resizeTimer); }
      Landmarks.resizeTimer = setTimeout(function() {
        MoshiMap.moshiMap.map.setSize(
          new MQA.Size(_mapContainer.width(), _mapContainer.height())
        );
      }, 500);
    }
  }
};

/* Initializer */
jQuery(function() {
  q('#mapContainer').moshiMap().init();
  Landmarks.init();
});
