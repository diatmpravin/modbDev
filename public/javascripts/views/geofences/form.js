/**
 * Handle form logic on the geofences/edit and geofences/new pages
 */
if(typeof Geofence == "undefined") {
  Geofence = {};
}

Geofence.Form = function(container) {
  var self = this;

  this._container = container;
  this._form = container.find("form");

  q("#sidebar").corners("transparent");

  q("#shapeChooser a").live("click", function() { self.changeShape(q(this)); });

  this._container.fitWindow(function(newWidth, newHeight) {
    self.resize(newWidth, newHeight);
  });

  this.geofence = new Geofence.Model(this._getGeofenceType(), this._getCoordinates());
  this.view = new Geofence.View(this.geofence, this);
}

Geofence.Form.prototype = {
  /**
   * Change the shape of the geofence we're working with.
   * This updates the model, then informs the view to rebuild it's knowledge
   * of the geofence.
   */
  changeShape: function(link) {
    q(link).addClass('selected').siblings('a').removeClass('selected');
    var newType = this._getGeofenceType()

    if(this.geofence.getType() != newType) {
      this.geofence.setType(newType);
      this.view.geofenceTypeChanged();
    }
  }
  ,
  /**
   * Resize the form when the window changes, keeping everything
   * in proper proportion
   */
  resize: function(newWidth, newHeight) {
    newHeight = Math.max(350, newHeight);
    this._container.height(newHeight - 32);
    this._container.find('#sidebar').height(newHeight - 32 - 16);
    this._container.find('#sidebarContent').height(newHeight - 32 - 32);
  }  
  ,
  /**
   * What's the width of this form in pixels?
   */
  width: function() {
    return this._container.outerWidth();
  }
  ,
  /**
   * Get the type of geofence
   */
  getGeofenceType: function() {
    return this.geofence.getType();
  }
  ,

  /*****************
   * Private methods
   *****************/

  /**
   * Read the geofence type from the form
   */
  _getGeofenceType: function() {
    return parseInt(this._form.find("#shapeChooser a.selected").attr("href").substring(1));
  }
  ,
  /**
   * Read the array of coordinates from the form.
   */
  _getCoordinates: function() {
    var coords = [], coordsDiv = this._form.find(".coordinates"), i = 0;

    coordsDiv.find('input[name=\'geofence[coordinates][][latitude]\']').each(function() {
      coords[coords.length] = [this.value];
    });

    coordsDiv.find('input[name=\'geofence[coordinates][][longitude]\']').each(function() {
      coords[i++].push(this.value);
    });

    return coords;
  }
};

jQuery(function() {
  new Geofence.Form(q("#sidebarContainer"));
});
