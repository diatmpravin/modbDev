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
    var newType = this._getGeofenceType();

    if(this.geofence.getType() != newType) {
      this._form.find('input[name=\'geofence[geofence_type]\']').val(newType);

      this.geofence.setType(newType);
      this.view.geofenceTypeChanged(newType);
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
  /**
   * Given an array of [lat, lng] points, update
   * the model to use these new coordinates and update
   * our form for saving
   */
  updateModel: function(coords) {
    this.geofence.setCoordinates(coords);
    var coordsDiv = this._form.find("#coordinates");
    coordsDiv.empty();

    for(var i = 0; i < coords.length; i++) {
      coordsDiv.append(
        '<input type="hidden" name="geofence[coordinates][][latitude]" value="' + coords[i][0] + '"/>'
      ).append(
        '<input type="hidden" name="geofence[coordinates][][longitude]" value="' + coords[i][1] + '"/>'
      );
    }
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
    var coords = [], coordsDiv = this._form.find("#coordinates"), i = 0;

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
