/**
 * Fleet.Frame.GeofenceEditPane
 *
 * Represents the overlay pane the user sees while editing a geofence.
 */
var Fleet = Fleet || {};
Fleet.Frame = Fleet.Frame || {};
Fleet.Frame.GeofenceEditPane = (function(GeofenceEditPane, Fleet, $) {
  var width = 200,
      pane,
      content,
      init = false;
  
  /**
   * init()
   *
   * Create and prepare the Geofence Edit pane.
   */
  GeofenceEditPane.init = function() {
    if (init) {
      return GeofenceEditPane;
    }
    
    // Create the geofence edit pane
    $('#frame').append('<div id="geofence_edit_pane"><div class="content"></div></div>');
    
    // Store a permanent reference to the pane
    pane = $('#geofence_edit_pane');
    
    // A reference to our content
    content = pane.children('.content');
    
    // Shape Chooser
    $('#shapeChooser a').live('click', function() {
      if ($(this).hasClass('selected')) {
        return false;
      }
      
      var newType = parseInt(this.href.substring(this.href.indexOf('#') + 1));
      $(this).addClass('selected')
             .siblings('a').removeClass('selected')
             .siblings('input').val(newType);
             
      return Fleet.Controller.convertShape(newType);
    });
    
    init = true;
    return GeofenceEditPane;
  };
  
  /**
   * initPane(html)
   *
   * Replace the pane's content with the given HTML.
   */
  GeofenceEditPane.initPane = function(html) {
    if (html) {
      content.html(html);
      
      // Hack - select the ellipse if it's a new geofence
      if ($('#shapeChooser input').val() == '') {
        $('#shapeChooser a:first').addClass('selected');
        $('#shapeChooser input').val(0);
      }
    }
    
    return GeofenceEditPane;
  };
  
  /**
   * open()
   *
   * Open the geofence edit pane.
   */
  GeofenceEditPane.open = function() {
    pane.animate({opacity: 0.9, right: 8}, {duration: 400});
    
    return GeofenceEditPane;
  };
  
  /**
   * close()
   *
   * Close the landmark edit pane.
   */
  GeofenceEditPane.close = function() {
    pane.animate({opacity: 0, right: 0 - (width + 8)}, {duration: 400});
    
    return GeofenceEditPane;
  };
  
  /**
   * submit(options)
   *
   * Used by the controller to submit the edit pane form. The options
   * passed in will be forwarded to the ajaxSubmit method.
   */
  GeofenceEditPane.submit = function(options) {
    pane.find('form:first').ajaxSubmit(options);
    
    return GeofenceEditPane;
  };
  
  /**
   * coordinates()
   *
   * Return the coordinates of the geofence being edited, converting them
   * into an array of points formatted as {latitude:x, longitude:y}.
   *
   * coordinates(list)
   * coordinates(LatLngCollection)
   *
   * Set the coordinates of the geofence being edited to the given list
   * of points. Can be passed as an array (like our Geofence JSON) or
   * an MQA.LatLngCollection.
   */
  GeofenceEditPane.coordinates = function(a) {
    var text = '', idx, num, list;
    
    if (a) {
      if (a.getM_Items) {
        a = a.getM_Items();
        for(idx = 0, num = a.length; idx < num; idx++) {
          text += a[idx].lat + ',' + a[idx].lng + ',';
        }
      } else {
        for(idx = 0, num = a.length; idx < num; idx++) {
          text += a[idx].latitude + ',' + a[idx].longitude + ',';
        }
      }
      
      pane.find('form:first .coordinates').val(text.substring(0, text.length - 1));
    }
    
    text = pane.find('form:first .coordinates').val();
    text = text.split(',');
    list = [];
    
    for(idx = 0, num = text.length; idx < num;) {
      list.push({
        latitude: text[idx++],
        longitude: text[idx++]
      });
    }
    
    return list;
  };
  
  /**
   * groups()
   *
   * Return an array of the currently selected group ids.
   *
   * groups(array)
   *
   * Select the given array of group ids in the form.
   */
  GeofenceEditPane.groups = function(arr) {
    var idx, num,
        select = pane.find('select.groups');
    
    if (arr) {
      select.children('option').attr('selected', false);
      
      for(idx = 0, num = arr.length; idx < num; idx++) {
        select.children('option[value=' + arr[idx] + ']').attr('selected', true);
      }
    } else {
      var active = select.children('option[selected=true]');
      arr = [];
      
      for(idx = 0, num = active.length; idx < num; idx++) {
        arr.push(active[idx].value);
      }
    }
    
    return arr;
  };
  
  return GeofenceEditPane;
}(Fleet.Frame.GeofenceEditPane || {}, Fleet, jQuery));
