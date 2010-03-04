/**
 * Handle form logic on the geofences/edit and geofences/new pages
 */
if(typeof Geofence == 'undefined') {
  Geofence = {};
}

Geofence.Form = function(form) {
  var self = this;

  this._form = form;
  
  q('#shapeChooser a').live('click', function() {
    self.changeShape(q(this));
    return false;
  });
  
  q('#map').css('position','fixed');
  q('#map').css('top','80px');
  q('#map').css('right','32px');
  
  /*this._map.fitWindow(self.resize);*/

  // Initialize our map
  this._map = new Map.View();

  // Handle new, where there isn't a shape yet
  if(this._getGeofenceType()) {
    this.buildGeofence();
  }
  
/**
 * .fitWindow(function(width, height))
 *
 * Register an element as being resizable, aka hooking into the
 * 'resize' event, allowing elements on the page to update
 * to fit the browser window size.
 *
 * function should take two parameters: width and height. Use this
 * callback to do the actual resizing of elements as necessary.
 *
 * I was going to go with .resizable, but jquery UI has that taken.
 *
jQuery.fn.fitWindow = function(callback) {
  var _self = q(this);
  q(window).resize(function(event) {
    callback(
      q(window).width(),
      q(window).height() - _self.position().top - 1
    );
  });

  // And run once to ensure a good start case
  q(window).resize();
}*/
  
}

Geofence.Form.prototype = {
  /**
   * Construct a new Geofence and View and hook them together
   */
  buildGeofence: function() {
    this.geofence = new Geofence.Model(this._getGeofenceType(), this._getCoordinates());
    this.view = new Geofence.View(this._map, this.geofence, this);
  }
  ,
  /**
   * Change the shape of the geofence we're working with.
   * This updates the model, then informs the view to rebuild it's knowledge
   * of the geofence.
   */
  changeShape: function(link) {
    q(link).addClass('selected').siblings('a').removeClass('selected');
    var newType = this._getGeofenceType();

    this._form.find('input[name=\'geofence[geofence_type]\']').val(newType);

    if(!this.geofence) { 
      this.buildGeofence(); 
    } else if(this.geofence.getType() != newType) {
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
    /*newHeight = Math.max(425, newHeight);
    
    newHeight = Math.max(425, newHeight);
    this._container.height(newHeight - 32);
    this._container.find('#sidebar').height(newHeight - 32 - 16);
    this._container.find('#sidebarContent').height(newHeight - 32 - 32);*/
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
    var selected = this._form.find("#shapeChooser a.selected");

    if(selected.length > 0) {
      return parseInt(selected.attr("href").substring(1));
    } else {
      return null;
    }
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
  new Geofence.Form(q('#content form'));
});
