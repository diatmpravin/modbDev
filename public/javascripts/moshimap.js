/* Define the proxy used for remote API calls to MapQuest */
MoshiProxy = {
  localServer: "",
  localPort: "",
  localPath: "proxy",
  remoteServer: {
    route: "route.access.mapquest.com",
    geocode: "geocode.access.mapquest.com",
    search: "search.access.mapquest.com"
  },
  remotePort: "80",
  remotePath: "mq"
};

/* MapQuest Suggested Fix for "Teleporting" Polygons */
(function() {
  var override = MQA.ShapeOverlay;
  MQA.ShapeOverlay = function() {
    override.call(this);
    this._adjustXY = function(XY) {
      XY.x = XY.x - parseInt(this.map.overlaydiv.style.left) - this.map.getDragOffset().x;
      XY.y = XY.y - parseInt(this.map.overlaydiv.style.top) - this.map.getDragOffset().y;
      return XY;
    }
  };
})();

(function(q) {
  /* jQuery Extension */
  
  /**
   * Return the linked MoshiMap object, creating it if it does not exist. The
   * first div element in the jQuery selection will be used to create and
   * retrieve the MoshiMap object.
   *
   * This is the preferred way to create or access a MoshiMap object.
   *
   * Note: this function does NOT return a jQuery object, so it cannot be used
   * in jQuery chains.
   *
   * @return a MoshiMap object, or undefined if no div is selected
   */
  q.fn.extend({
    moshiMap: function() {
      var div = this.filter('div').get(0);
      if (div) {
        return q(div).data("map") || new MoshiMap(div);
      }
    }
  });
  
  /* MoshiMap */
  
  /**
   * Create and return a new MoshiMap object. It will be linked to the
   * provided container. This container should always be a div,
   * due to MapQuest restrictions.
   *
   * Note: the actual MapQuest API will not be initialized until you call
   * init() on the returned MoshiMap object!
   *
   * @param  mapContainer a jQuery object or selector string
   * @return              a MoshiMap object
   */
  MoshiMap = function(mapContainer) {
    this.mapContainer = q(mapContainer);
    this.map = null;
    this.boundingBox = null;
    this.points = [];
    this.remote = null;
    this.trip = null;
    this.pointCollection = new MQA.ShapeCollection();
    this.geofenceCollection = new MQA.ShapeCollection();
    this.tempCollection = new MQA.ShapeCollection();
    
    // By default, zoom out directly over the U.S.
    this.focus = {
      lat: 37.877414,
      lng: -94.697259,
      zoom: 2
    };
    
    // Allow access to this object through the container
    this.mapContainer.data("map", this);
    
    // Allow access globally through MoshiMap.moshiMap
    MoshiMap.moshiMap = this;
  };

  /**
   * Initialize and display the MapQuest interface. It will be displayed
   * within the linked container. (Any content previously displayed in the
   * container will be removed.)
   */
  MoshiMap.prototype.init = function() {
    // Force jQuery to copy stylesheet info into the container's style.
    // (For MapQuest to initialize properly, width and height must exist
    // as part the containing element's .style attribute.)
    this.mapContainer.width(this.mapContainer.width());
    this.mapContainer.height(this.mapContainer.height());
    
    this.boundingBox = new MQA.RectLL(new MQA.LatLng(), new MQA.LatLng());
    
    // If we know about at least one point, override the default focus
    if (this.points.length > 0) {
      this.focus.lat = this.points[0].lat;
      this.focus.lng = this.points[0].lng;
      this.focus.zoom = 13;
    }
    
    // Initialize the MapQuest map
    this.map = new MQA.TileMap(
      this.mapContainer.html('').get(0),
      this.focus.zoom,
      new MQA.LatLng(this.focus.lat, this.focus.lng)
    );
    
    this.map.setBestFitMargin(75);

    // Update the Rollover/Info Window to our custom specifications
    this.map.getInfoWindow().setMaxWidth(200);
    this.map.getInfoWindow().setMinWidth(200);
    this.map.getRolloverWindow().setTextLength(30);
    
    // Initialize any map controls
    this.map.addControl(new Moshi.ZoomControl(),
      new MQA.MapCornerPlacement(MQA.CORNER_TOPLEFT, new MQA.Size(14, 32))
    );
    this.map.addControl(new Moshi.ViewControl(),
      new MQA.MapCornerPlacement(MQA.CORNER_TOPLEFT, new MQA.Size(16, 0))
    );
    
    // Logo in bottom-left corner
    this.map.setLogoPlacement(MQA.MapLogo.MAPQUEST,
      new MQA.MapCornerPlacement(MQA.CORNER_BOTTOMLEFT, new MQA.Size(0, 16))
    );
    
    // Points or shapes added to these collections will display on the map
    this.map.addShapeCollection(this.pointCollection);
    this.map.addShapeCollection(this.geofenceCollection);
    this.map.addShapeCollection(this.tempCollection);
    
    // Handle MapQuest's buggy cursor on mouseUp
    MQA.EventManager.addListener(this.map, 'mouseup', MoshiMap.resetCursor);
    
    // Add mousewheel support -- maybe someday this will be built in
    q(this.mapContainer).bind('mousewheel', MoshiMap.mapScroll);
    
    // Controls are hover-only
    q(this.mapContainer).hover(function() {
      q('.moshiViewControl').stop(true, false).animate({top:0,opacity:1}, 'slow');
      q('.moshiZoomControl').stop(true, false).animate({left:14,opacity:1}, 'slow');
    }, function() {
      q('.moshiViewControl').stop(true, false).animate({top:-22,opacity:0}, 'slow');
      q('.moshiZoomControl').stop(true, false).animate({left:-64,opacity:0}, 'slow');
    });
  };
  
  /**
   * Clear any existing points and then display the points from the given
   * trip. The map will be panned and zoomed to fit the entire trip on
   * the screen.
   *
   * @param trip a JSONified Trip object
   */
  MoshiMap.prototype.displayTrip = function(trip) {
    this.trip = trip;
    this.points = [];
    
    this.pointCollection.removeAll();
    
    for(var i = 0; i < this.trip.legs.length; i++) {
      var leg = this.trip.legs[i];
      
      for(var j = 0; j < leg.displayable_points.length; j++) {
        var point = leg.displayable_points[j];
        
        var title = point.time_of_day + '  ';

        if(point.speed == 0) {
          title += "<i>Idle</i>";
        } else {
          title += '<i>' + point.speed + ' mph</i>';
        }

        var description = '';
        for(var k = 0; k < point.events.length; k++) {
          description += point.events[k].type_text + '<br/>';
        }
        if (description == '') {
          description = 'No events';
        }
        
        if (j==0) {
          this.addPoint(point, {
            icon: trip.color.filename.match(/(.*?)\.png/)[1] + '_start.png',
            size: [21, 21],
            offset: [-10, -10],
            title: title,
            description: description
          });
        } else if (j==leg.displayable_points.length-1) {
          this.addPoint(point, {
            icon: trip.color.filename.match(/(.*?)\.png/)[1] + '_stop.png',
            size: [21, 21],
            offset: [-10, -10],
            title: title,
            description: description
          });
        } else if (point.events.length > 0) {
          this.addPoint(point, {
            icon: trip.color.filename.match(/(.*?)\.png/)[1] + '_event.png',
            size: [21, 21],
            offset: [-10, -10],
            title: title,
            description: description
          });
        } else {
          this.addPoint(point, {
            icon: trip.color.filename,
            size: [11, 11],
            offset: [-5, -5],
            title: title,
            description: description
          });
        }
      }
    }
    
    this.bestFit();
  };
  
  /**
   * Pan the map to the Nth point in the list of currently displayed points.
   *
   * @param pointNumber the index of the point to pan to
   */
  MoshiMap.prototype.panToPoint = function(pointNumber) {
    this.map.panToLatLng(this.pointCollection.getAt(pointNumber).latLng);
  };

  /**
   * Close any popup window, info or rollover.
   * Do this to prevent an IE 7 script error.
   */
  MoshiMap.prototype.closePopups = function() {
    this.map.getInfoWindow().hide();
    this.map.getRolloverWindow().hide();
  };
  
  /**
   * Add an individual point to our list of displayed points.
   *
   * @param point   a JSONified Point object
   * @param options an options hash, with the following optional keys:
   *                  icon
   *                  title
   *                  description
   *                  size
   *                  offset
   */
  MoshiMap.prototype.addPoint = function(point, options) {
    var mqLoc = new MQA.LatLng(point.latitude, point.longitude);
    var mqPoi = new MQA.Poi(mqLoc);
    
    if (options.icon) {
      mqPoi.setValue('icon', new MQA.Icon(options.icon, options.size[0], options.size[1]));
      mqPoi.setValue('iconOffset', new MQA.Point(options.offset[0], options.offset[1]));
      mqPoi.setValue('shadow', new MQA.Icon('/images/blank.gif'));
    }
    
    if (options.title) {
      mqPoi.setValue('rolloverEnabled', true);
      mqPoi.setValue('infoTitleHTML', options.title);
    }
    
    if (options.description) {
      mqPoi.setValue('infoContentHTML', options.description);
    }
    
    if (options.label) {
      mqPoi.setValue('labelText', options.label);
      mqPoi.setValue('labelClass', 'mapLabel');
      mqPoi.setValue('labelVisible', false);
    }
    
    mqPoi.moshiPoint = point;
    this.pointCollection.add(mqPoi);
    
    return mqPoi;
  };
  
  /**
   * Clear any points currently being displayed on the map.
   */
  MoshiMap.prototype.clearPoints = function() {
    this.pointCollection.removeAll();
  };
  
  /**
   * Best-fit the map around the collection of points currently being
   * displayed.
   */
  MoshiMap.prototype.bestFit = function() {
    var mqPointList = [];
    
    for(var i = 0; i < this.pointCollection.getSize(); i++) {
      mqPointList.push(this.pointCollection.getAt(i).latLng);
    }
    
    this.map.bestFitLL(mqPointList, false, 4, 13);
  };
  
  /**
   * Set the specified cursor style for all map tile elements.
   */
  MoshiMap.prototype.crosshair = function(showCrosshair) {
    if (showCrosshair || 'undefined' == typeof showCrosshair) {
      q('#mapContainer').addClass('crosshair');
      q('#mqOverlayDiv').css('cursor', 'crosshair');
    } else {
      q('#mapContainer').removeClass('crosshair');
      q('#mqOverlayDiv').css('cursor', '-moz-grab');
    }
  };
  
  /**
   * Event handler called on mouseUp events to prevent MapQuest from randomly
   * changing the mouse cursor.
   */
  MoshiMap.resetCursor = function() {
    if (MoshiMap.moshiMap.mapContainer.hasClass('crosshair')) {
      q('#mqOverlayDiv').css('cursor', 'crosshair');
    }
  };
  
  /**
   * Event handler called on mousewheel events within the map container.
   */
  MoshiMap.mapScroll = function(event, delta) {
    // Save the lat/long position the cursor is currently scrolling over, and
    // adjust the map after zoom so that the cursor is over the same lat/long.
    
    var scrollX = event.pageX - MoshiMap.moshiMap.mapContainer.position().left,
        scrollY = event.pageY - MoshiMap.moshiMap.mapContainer.position().top,
        centerX = MoshiMap.moshiMap.mapContainer.width() / 2,
        centerY = MoshiMap.moshiMap.mapContainer.height() / 2;
    
    var ll = MoshiMap.moshiMap.map.pixToLL(new MQA.Point(scrollX, scrollY));
    
    if (delta > 0) {
      MoshiMap.moshiMap.map.zoomIn();
    } else if (delta < 0) {
      MoshiMap.moshiMap.map.zoomOut();
    }
    
    var offsetPoint = MoshiMap.moshiMap.map.llToPix(ll);
    offsetPoint.x = centerX + (offsetPoint.x - scrollX);
    offsetPoint.y = centerY + (offsetPoint.y - scrollY);
    
    MoshiMap.moshiMap.map.setCenter(MoshiMap.moshiMap.map.pixToLL(offsetPoint));
    
    return false;
  };
})(jQuery);
