/**
 * Handle form logic on the geofences/edit and geofences/new pages
 */
if(typeof Landmark == 'undefined') {
  Landmark = {};
}

Landmark.Form = function(form) {
  q('div.groupSelect').groupSelect();
}

jQuery(function() {
  new Landmark.Form(q('#content form'));
});
