/**
 * Geofences
 *
 * Constants and functions used on the Geofence Settings page.
 */
Geofences = {
  ELLIPSE: 0,
  RECTANGLE: 1,
  POLYGON: 2,
  editMode: false,
  fences: [],
  fence: null,

  init: function() {
    Geofences.corners();
    
    q('#show_landmarks').change(LandmarksView.updateVisibility).attr('checked', false);
    
    q('#addGeofence').live('click', Geofences.newGeofence);
    q('div.geofence[id=new] input.save').live('click', Geofences.create);
    q('div.geofence[id=new] input.cancel').live('click', Geofences.cancelNew);
    
    q('div.geofence input.edit').live('click', Geofences.edit);
    q('div.geofence[id!=new] input.save').live('click', Geofences.save);
    q('div.geofence[id!=new] input.cancel').live('click', Geofences.cancel);
    
    q('div.geofence input.delete').live('click', function() {
      q('#removeGeofence').dialog('open').data('geofence', q(this).closest('div.geofence'));
    });
    
    q('div.geofence .shapeChooser a').live('click', Geofences.changeShape);
    
    q('div.geofence').live('mouseover', function() {
      q('div.view .buttons').hide();
      q(this).find('.buttons').show();
    }).live('mouseout', function() {
      q('div.view .buttons').hide();
    });
    
    q("#removeGeofence").dialog({
      title: 'Remove Geofence',
      modal: true,
      autoOpen: false,
      resizable: false,
      width: 450,
      buttons: {
        'Yes, delete this geofence': Geofences.destroy,
        'No, do not delete': function() { q(this).dialog('close'); }
      }
    });
    
    q(window).resize(Geofences.resize);
    Geofences.resize();
    
    Geofences.buildGeofences();
  }
  ,
  /**
   * Show the new geofence form and an associated geofence on the map.
   */
  newGeofence: function() {
    q('#new').show('fast').siblings('.geofence').hide('fast');
    q('#new').find('a.ellipse').addClass('selected');
    
    q('#addGeofence').hide('fast');
    Geofences.enterFenceMode(null, q('#new'));
  }
  ,
  /**
   * Submit a new geofence.
   */
  create: function() {
    var _new = q('#new');
    
    Geofences.storeGeofence(Geofences.fence, _new);
    _new.find('form').ajaxSubmit({
      dataType: 'json',
      beforeSubmit: function() { _new.find('.loading').show(); },
      success: function(json) {
        if (json.status == 'success') {
          q('#addGeofence').show('fast');
          
          _new.hide('fast', function() {
            q.get('/geofences/new', function(html) {
              _new.html(html);
              AlertRecipients.prepare(_new);
            });
          }).siblings('.geofence').show('fast');
          Geofences.exitFenceMode();
          
          var _div = q('<div class="geofence" style="display:none"><div class="view">'
            + json.view
            + '</div><div class="edit">'
            + json.edit
            + '</div></div>').insertAfter('#new').show('fast');
          AlertRecipients.prepare(_div);
          
          var fence = {};
          Geofences.loadGeofence(_div, fence);
          if (fence.shape) {
            Geofences.fences[Geofences.fences.length] = fence;
            _div.data('fence', fence);
          }
        } else {
          _new.html(json.html);
        }
      }
    });
  }
  ,
  /**
   * Hide the new geofence form and associated geofence on the map.
   */
  cancelNew: function() {
    var _new = q('#new');
    q('#addGeofence').show('fast');
    
    _new.hide('fast', function() {
      q.get('/geofences/new', function(html) {
        _new.html(html);
        AlertRecipients.prepare(_new);
      });
    }).siblings('.geofence').show('fast');
    
    Geofences.exitFenceMode();
  }
  ,
  /**
   * Show the user the edit form for an existing geofence.
   */
  edit: function() {
    var _geofence = q(this).closest('div.geofence');
    q('#addGeofence').hide('fast');
    
    _geofence.siblings('div.geofence').hide('fast').end()
             .find('div.edit').show('fast').end()
             .find('div.view').hide('fast');
    
    Geofences.enterFenceMode(_geofence.data('fence'), _geofence);
  }
  ,
  /**
   * Submit changes to an existing geofence.
   */
  save: function() {
    var _edit = q(this).closest('div.edit'),
        _geofence = _edit.closest('div.geofence');
    
    Geofences.storeGeofence(Geofences.fence, _geofence);
    _edit.find('form').ajaxSubmit({
      dataType: 'json',
      beforeSubmit: function() { _edit.find('.loading').show(); },
      success: function(json) {
        if (json.status == 'success') {
          q('#addGeofence').show('fast');
          _geofence.siblings('div.geofence[id!=new]').show('fast').end()
                   .find('div.view').html(json.view).show('fast');
          
          _edit.hide('fast', function() {
            _edit.html(json.edit);
            AlertRecipients.prepare(_geofence);
          });
        } else {
          _edit.html(json.html);
        }
      }
    });
    
    Geofences.exitFenceMode();
  }
  ,
   /**
   * Hide the edit form for an existing landmark.
   */
  cancel: function() {
    var _edit = q(this).closest('div.edit');
    var _landmark = _edit.closest('div.landmark');
    
    q('#addLandmark').show('fast');
    _landmark.siblings('div.landmark[id!=new]').show('fast').end()
             .find('div.view').show('fast').end()
             .find('div.edit').hide('fast', function() {
                q.get(_edit.find('form').attr('action') + '/edit', function(html) {
                  _edit.html(html);
                  Landmarks.createMapLandmark(_landmark).setValue('draggable', false);
                });
              });
    Landmarks.highlightMapLandmark();
  }
  ,
  /**
   * Hide the edit form for an existing geofence.
   */
  cancel: function() {
    var _edit = q(this).closest('div.edit'),
        _geofence = _edit.closest('div.geofence');
    
    q('#addGeofence').show();
    _geofence.siblings('div.geofence[id!=new]').show('fast').end()
             .find('div.view').show('fast').end()
             .find('div.edit').hide('fast', function() {
               q.get(_edit.find('form').attr('action') + '/edit', function(html) {
                 _edit.html(html);
                 AlertRecipients.prepare(_geofence);
               });
             });
    
    Geofences.loadGeofence(_geofence, Geofences.fence);
    Geofences.exitFenceMode();
  }
  ,
  /**
   * Delete an existing geofence and associated geofence on the map.
   */
  destroy: function() {
    var _dialog = q(this);
    var _geofence = q(this).data('geofence');
    
    _geofence.find('div.edit form').ajaxSubmit({
      dataType: 'json',
      type: 'DELETE',
      beforeSubmit: function() { _dialog.dialogLoader().show(); },
      complete: function() { _dialog.dialog('close').dialogLoader().hide(); },
      success: function(json) {
        if (json.status == 'success') {
          if (_geofence.data('fence')) {
            MoshiMap.moshiMap.geofenceCollection.removeItem(_geofence.data('fence').shape);
          }
          
          _geofence.hide('fast', function() {
            _geofence.remove();
          });
        } else {
          location.reload();
        }
      }
    });
  }
  ,
  corners: function(elem) {
    q('#sidebar').corners('transparent');
  }
  ,
  /**
   * TODO: This code is on at least three pages almost verbatim, massage it into a
   * generic function and stick it in a file by itself.
   */  
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
    q('#sidebarContent').height(mapHeight - 32 - 32);
    
    var margin = q('.geofences').position().top - q('#sidebar').position().top;
    var height = q('#sidebar').outerHeight() - 16;
    var newHeight = height - margin;
    q('.geofences').css('height', newHeight);
    
    if (MoshiMap.moshiMap) {
      // Introduce an artificial delay to avoid MapQuest resize bugs
      if (Geofences.resizeTimer) { clearTimeout(Geofences.resizeTimer); }
      Geofences.resizeTimer = setTimeout(function() {
        MoshiMap.moshiMap.map.setSize(
          new MQA.Size(_mapContainer.width(), _mapContainer.height())
        );
      }, 500);
    }
  }
  ,
  /**
   * Take the initial list of geofences, build their shape objects, and
   * display them all on the map using best fit. Called once at page load.
   */
  buildGeofences: function() {
    Geofences.fences = [];
    
    q('.geofence').each(function() {
      var fence = {};
      
      Geofences.loadGeofence(q(this), fence);
      if (fence.shape) {
        Geofences.fences[Geofences.fences.length] = fence;
        q(this).data('fence', fence);
      }
    });
    
    var bounds = MoshiMap.moshiMap.geofenceCollection.getBoundingRect();
    if (bounds) { // if there are any geofences
      MoshiMap.moshiMap.map.bestFitLL([bounds.ul, bounds.lr]);
    }
  }
  ,
  /**
   * Fade out all fence shapes not being edited, highlight the shape being
   * edited, and setup the appropriate event handlers for dragging/resizing.
   */
  enterFenceMode: function(fence, container) {
    var _mapContainer = q('#mapContainer');
    var centerX = _mapContainer.width() / 2;
    var centerY = _mapContainer.height() / 2;
    
    for(var i = 0; i < Geofences.fences.length; i++) {
      Geofences.setFenceColor(Geofences.fences[i], '#aaaaaa');
    }
    
    if (fence == null) {
      var tl = MoshiMap.moshiMap.map.pixToLL(new MQA.Point(centerX-50, centerY-50));
      var br = MoshiMap.moshiMap.map.pixToLL(new MQA.Point(centerX+50, centerY+50));
      Geofences.fence = {
        type: 0,
        coords: [
          {latitude: tl.lat, longitude: tl.lng},
          {latitude: br.lat, longitude: br.lng}
        ]
      };
      Geofences.shape(Geofences.fence);
      MoshiMap.moshiMap.tempCollection.add(Geofences.fence.shape);
    } else {
      Geofences.fence = fence;
      Geofences.setFenceColor(Geofences.fence, '#ff0000');
    }
    
    // Focus on new shape
    var temp = new MQA.ShapeCollection();
    temp.add(Geofences.fence.shape);
    var bounds = temp.getBoundingRect();
    MoshiMap.moshiMap.map.bestFitLL([bounds.ul, bounds.lr]);
    
    MQA.EventManager.addListener(Geofences.fence.shape, 'mousedown', Geofences.dragStart);
    Geofences.createFenceHandles();
  }
  ,
  /**
   * Set all fence colors back to normal, delete any temporary shapes, and
   * remove any unneeded event handlers.
   */
  exitFenceMode: function() {
    MQA.EventManager.removeListener(Geofences.fence.shape, 'mousedown', Geofences.dragStart);
    Geofences.fence.pois = null;
    Geofences.fence = null;
    
    MoshiMap.moshiMap.tempCollection.removeAll();
    for(var i = 0; i < Geofences.fences.length; i++) {
      Geofences.setFenceColor(Geofences.fences[i], '#ff0000');
    }
    
    var bounds = MoshiMap.moshiMap.geofenceCollection.getBoundingRect();
    if (bounds) { // if there are any geofences
      MoshiMap.moshiMap.map.bestFitLL([bounds.ul, bounds.lr]);
    }
  }
  ,
  /**
   * Prepare a fence shape for dragging.
   */
  dragStart: function(mqEvent) {
    MoshiMap.moshiMap.map.enableDragging(false);
    q('#mapContainer').bind('mousemove.geofence', Geofences.drag);
    q('#mapContainer').bind('mouseup.geofence', Geofences.dragEnd);
    
    var clientX = mqEvent.domEvent.clientX - q('#mapContainer').position().left - q('#mqtiledmap').position().left;
    var clientY = mqEvent.domEvent.clientY - q('#mapContainer').position().top - q('#mqtiledmap').position().top;
    
    Geofences.fenceOffset = [];
    for(var i = 0; i < Geofences.fence.shape.shapePoints.getSize(); i++) {
      var xy = MoshiMap.moshiMap.map.llToPix(Geofences.fence.shape.shapePoints.getAt(i));
      Geofences.fenceOffset[Geofences.fenceOffset.length] = [
        xy.x - clientX, xy.y - clientY
      ];
    }
    for(var i = 0; i < Geofences.fence.pois.length; i++) {
      Geofences.fence.pois[i].setValue('visible', false);
    }
  }
  ,
  /**
   * Handle a drag event.
   */
  drag: function(event) {
    var clientX = event.clientX - q('#mapContainer').position().left - q('#mqtiledmap').position().left;
    var clientY = event.clientY - q('#mapContainer').position().top - q('#mqtiledmap').position().top;
    var coll = new MQA.LatLngCollection();
    for(var i = 0; i < Geofences.fenceOffset.length; i++) {
      coll.add(MoshiMap.moshiMap.map.pixToLL(new MQA.Point(
        Geofences.fenceOffset[i][0] + clientX,
        Geofences.fenceOffset[i][1] + clientY
      )));
    }
    
    Geofences.fence.shape.setShapePoints(coll);
  }
  ,
  /**
   * Cleanup after a shape has been dragged.
   */
  dragEnd: function(event) {
    var clientX = event.clientX - q('#mapContainer').position().left - q('#mqtiledmap').position().left;
    var clientY = event.clientY - q('#mapContainer').position().top - q('#mqtiledmap').position().top;
    var coll = new MQA.LatLngCollection();
    for(var i = 0; i < Geofences.fenceOffset.length; i++) {
      coll.add(MoshiMap.moshiMap.map.pixToLL(new MQA.Point(
        Geofences.fenceOffset[i][0] + clientX,
        Geofences.fenceOffset[i][1] + clientY
      )));
    }
    
    MoshiMap.moshiMap.map.enableDragging(true);
    q('#mapContainer').unbind('mousemove.geofence');
    q('#mapContainer').unbind('mouseup.geofence');
    
    Geofences.createFenceHandles();
  }
  ,
  /**
   * Start dragging a geofence corner.
   */
  dragCornerStart: function(mqEvent) {
    Geofences.corner = this;
    q('#mapContainer').bind('mousemove.geofence', Geofences.dragCorner);
  }
  ,
  /**
   * Handle corner while it is being dragged.
   * NOTE: Currently only keeps track of how close it is to other corners.
   * It would be cool if this function updated the actual geofence shape.
   */
  dragCorner: function(event) {
    var clientX = event.clientX - q('#mapContainer').position().left - q('#mqtiledmap').position().left;
    var clientY = event.clientY - q('#mapContainer').position().top - q('#mqtiledmap').position().top;
    var mqPoi = Geofences.corner;
    
    for(var i = 0; i < Geofences.fence.pois.length; i++) {
      var otherPoi = Geofences.fence.pois[i];
      mqPoi.deleting = false;
      if (otherPoi.coordIndex != mqPoi.coordIndex && !otherPoi.coordNew) {
        var xy = MoshiMap.moshiMap.map.llToPix(otherPoi.getLatLng());
        if (Math.abs(xy.x-clientX) < 6 && Math.abs(xy.y-clientY) < 6) {
          mqPoi.deleting = true;
          break;
        }
      }
    }
  }
  ,
  /**
   * Cleanup after a corner has been dragged.
   */
  dragCornerEnd: function(event) {
    var mqPoi = Geofences.corner;
    q('#mapContainer').unbind('mousemove.geofence');
    
    Geofences.fence.points = new MQLatLngCollection();
    if (Geofences.fence.type == Geofences.POLYGON) {
      for(var i = 0; i < Geofences.fence.shape.shapePoints.getSize(); i++) {
        if (i == mqPoi.coordIndex) {
          if (mqPoi.coordNew) {
            Geofences.fence.points.add(Geofences.fence.shape.shapePoints.getAt(i));
          }
          if (!mqPoi.deleting) {
            Geofences.fence.points.add(mqPoi.getLatLng());
          }
        } else {
          Geofences.fence.points.add(Geofences.fence.shape.shapePoints.getAt(i));
        }
      }
    } else if (Geofences.fence.type == Geofences.RECTANGLE) {
      var otherPoi = Geofences.fence.pois[(mqPoi.coordIndex+2)%4];
      Geofences.fence.points.add(mqPoi.getLatLng());
      Geofences.fence.points.add(otherPoi.getLatLng());
    } else {
      var otherPoi = Geofences.fence.pois[(mqPoi.coordIndex+2)%4];
      var xy1 = MoshiMap.moshiMap.map.llToPix(mqPoi.getLatLng());
      var xy2 = MoshiMap.moshiMap.map.llToPix(otherPoi.getLatLng());
      var newxy1 = new MQA.Point((42 * xy1.x - 7 * xy2.x)/35, (42 * xy1.y - 7 * xy2.y)/35);
      var newxy2 = new MQA.Point((42 * xy2.x - 7 * xy1.x)/35, (42 * xy2.y - 7 * xy1.y)/35);
      Geofences.fence.points.add(MoshiMap.moshiMap.map.pixToLL(newxy1));
      Geofences.fence.points.add(MoshiMap.moshiMap.map.pixToLL(newxy2));
    }
    
    Geofences.fence.shape.setShapePoints(Geofences.fence.points);
    Geofences.createFenceHandles();
  }
  ,
  /**
   * Given a fence object, return a MapQuest shape. This function overrides
   * the shape and points of the given fence.
   */
  shape: function(fence) {
    if (fence.type == Geofences.ELLIPSE) {
      fence.shape = new MQA.EllipseOverlay();
    } else if (fence.type == Geofences.RECTANGLE) {
      fence.shape = new MQA.RectangleOverlay();
    } else if (fence.type == Geofences.POLYGON) {
      fence.shape = new MQA.PolygonOverlay();
    }
    
    fence.points = new MQLatLngCollection();
    for(var i = 0; i < fence.coords.length; i++) {
      fence.points.add(new MQA.LatLng(fence.coords[i].latitude, fence.coords[i].longitude));
    }
    
    fence.shape.setShapePoints(fence.points);
    Geofences.setFenceColor(fence, '#ff0000');
    
    return fence.shape;
  }
  ,
  /**
   * Create small POIs on the map at the corners of the current shape and
   * initialize any necessary event handlers. (These corners are used
   * for resizing the shape.)
   */
  createFenceHandles: function() {
    if (Geofences.fence.pois) {
      for(var i = 0; i < Geofences.fence.pois.length; i++) {
        MoshiMap.moshiMap.tempCollection.removeItem(Geofences.fence.pois[i]);
      }
    }
    
    // Create generic pois
    _create = function(ll, isCorner) {
      var mqPoi = new MQA.Poi(ll);
      if (isCorner) {
        mqPoi.setValue('icon', new MQA.Icon('/images/shape_handle_corner.png', 9, 9));
      } else {
        mqPoi.setValue('icon', new MQA.Icon('/images/shape_handle_edge.png', 9, 9));
      }
      mqPoi.setValue('iconOffset', new MQA.Point(-4, -4));
      mqPoi.setValue('draggable', true);
      mqPoi.setValue('shadow', null);
      MoshiMap.moshiMap.tempCollection.add(mqPoi);
      Geofences.fence.pois[Geofences.fence.pois.length] = mqPoi;
      MQA.EventManager.addListener(mqPoi, 'mousedown', Geofences.dragCornerStart);
      MQA.EventManager.addListener(mqPoi, 'mouseup', Geofences.dragCornerEnd);
      
      return mqPoi;
    };
    
    Geofences.fence.pois = [];
    if (Geofences.fence.type == Geofences.POLYGON) {
      for(var i = 0; i < Geofences.fence.shape.shapePoints.getSize(); i++) {
        var mqPoi = _create(Geofences.fence.shape.shapePoints.getAt(i), true);
        mqPoi.coordIndex = i;
        mqPoi.coordNew = false;
        
        var j = (i+1) % Geofences.fence.shape.shapePoints.getSize();
        var xy1 = MoshiMap.moshiMap.map.llToPix(Geofences.fence.shape.shapePoints.getAt(i));
        var xy2 = MoshiMap.moshiMap.map.llToPix(Geofences.fence.shape.shapePoints.getAt(j));
        var xy3 = new MQA.Point((xy1.x + xy2.x)/2, (xy1.y + xy2.y)/2);
        
        mqPoi = _create(MoshiMap.moshiMap.map.pixToLL(xy3), false);
        mqPoi.coordIndex = i;
        mqPoi.coordNew = true;
      }
    } else if (Geofences.fence.type == Geofences.RECTANGLE) {
      var c = [
        Geofences.fence.shape.shapePoints.getAt(0),
        Geofences.fence.shape.shapePoints.getAt(1)
      ];
      _create(new MQA.LatLng(c[0].lat, c[0].lng), true).coordIndex = 0;
      _create(new MQA.LatLng(c[0].lat, c[1].lng), true).coordIndex = 1;
      _create(new MQA.LatLng(c[1].lat, c[1].lng), true).coordIndex = 2;
      _create(new MQA.LatLng(c[1].lat, c[0].lng), true).coordIndex = 3;
    } else {
      var c = [
        MoshiMap.moshiMap.map.llToPix(Geofences.fence.shape.shapePoints.getAt(0)),
        MoshiMap.moshiMap.map.llToPix(Geofences.fence.shape.shapePoints.getAt(1))
      ];
      var xy = [
        new MQA.Point((6 * c[0].x + 1 * c[1].x)/7, (6 * c[0].y + 1 * c[1].y)/7),
        new MQA.Point((6 * c[1].x + 1 * c[0].x)/7, (6 * c[0].y + 1 * c[1].y)/7),
        new MQA.Point((6 * c[1].x + 1 * c[0].x)/7, (6 * c[1].y + 1 * c[0].y)/7),
        new MQA.Point((6 * c[0].x + 1 * c[1].x)/7, (6 * c[1].y + 1 * c[0].y)/7),
      ]
      _create(MoshiMap.moshiMap.map.pixToLL(xy[0]), true).coordIndex = 0;
      _create(MoshiMap.moshiMap.map.pixToLL(xy[1]), true).coordIndex = 1;
      _create(MoshiMap.moshiMap.map.pixToLL(xy[2]), true).coordIndex = 2;
      _create(MoshiMap.moshiMap.map.pixToLL(xy[3]), true).coordIndex = 3;
    }
  }
  ,
  /**
   * Convert a given Javascript fence object into a submit-ready set of form
   * coordinates. Assumes the given container is a jQuery object.
   */
  storeGeofence: function(fence, container) {
    var coords = container.find('.coordinates').empty();
    
    for(var i = 0; i < fence.shape.shapePoints.getSize(); i++) {
      var p = fence.shape.shapePoints.getAt(i);
      coords.append(
        '<input type="hidden" name="geofence[coordinates][][latitude]" value="' + p.lat + '"/>'
      ).append(
        '<input type="hidden" name="geofence[coordinates][][longitude]" value="' + p.lng + '"/>'
      );
    }
    
    container.find('input[name=\'geofence[geofence_type]\']').val(fence.type);
  }
  ,
  /**
   * Create a Javascript fence object based on the form inputs in the
   * given container. Assumes the container is a jQuery object.
   */
  loadGeofence: function(container, fence) {
    if (fence.shape && MoshiMap.moshiMap.geofenceCollection.contains(fence.shape)) {
      MoshiMap.moshiMap.geofenceCollection.removeItem(fence.shape);
      fence.shape = null;
    }
  
    fence.type = container.find('input[name=\'geofence[geofence_type]\']').val();
    if (!fence.type) { fence.type = 0; }
    fence.coords = [];
    
    container.find('input[name=\'geofence[coordinates][][latitude]\']').each(function() {
      fence.coords[fence.coords.length] = {latitude:this.value};
    });

    var i = 0;
    container.find('input[name=\'geofence[coordinates][][longitude]\']').each(function() {
      fence.coords[i].longitude = this.value;
      i += 1;
    });
    
    if (i > 0) {
      Geofences.shape(fence);
      MoshiMap.moshiMap.geofenceCollection.add(fence.shape);
    }
  }
  ,
  /**
   * Convert an existing fence shape into a (potentially) new shape when the
   * user toggles the fence type. If necessary, recreate any event handlers
   * for the shape.
   */
  changeShape: function() {
    var type = q(this).attr('href').substring(1);
    var fence = Geofences.fence;
    
    q(this).addClass('selected').siblings('a').removeClass('selected');
    
    if (fence.type == type) {
      return;
    }
    
    var corners = [360, 360, -360, -360];
    for(var i = 0; i < fence.shape.shapePoints.getSize(); i++) {
      var p = fence.shape.shapePoints.getAt(i);
      if (p.lat < corners[0]) { corners[0] = p.lat; }
      if (p.lng < corners[1]) { corners[1] = p.lng; }
      if (p.lat > corners[2]) { corners[2] = p.lat; }
      if (p.lng > corners[3]) { corners[3] = p.lng; }
    }
    
    var collection = MoshiMap.moshiMap.geofenceCollection;
    if (fence.shape && MoshiMap.moshiMap.geofenceCollection.contains(fence.shape)) {
      MoshiMap.moshiMap.geofenceCollection.removeItem(fence.shape);
    } else if (fence.shape && MoshiMap.moshiMap.tempCollection.contains(fence.shape)) {
      MoshiMap.moshiMap.tempCollection.removeItem(fence.shape);
      collection = MoshiMap.moshiMap.tempCollection;
    }
    
    fence.shape = null;
    fence.type = type;
    
    if (type == Geofences.ELLIPSE || type == Geofences.RECTANGLE) {
      fence.coords = [
        {latitude: corners[0], longitude: corners[1]},
        {latitude: corners[2], longitude: corners[3]}
      ];
    } else {
      fence.coords = [
        {latitude: corners[0], longitude: corners[1]},
        {latitude: corners[2], longitude: corners[1]},
        {latitude: corners[2], longitude: corners[3]},
        {latitude: corners[0], longitude: corners[3]}
      ];
    }
    
    Geofences.shape(fence);
    collection.add(fence.shape);
    MQA.EventManager.addListener(fence.shape, 'mousedown', Geofences.dragStart);
    
    Geofences.createFenceHandles();
    
    return false;
  }
  ,
  setFenceColor: function(fence, color) {
    fence.shape.setColor(color);
    fence.shape.setColorAlpha(0.5);
    fence.shape.setFillColor(color);
    fence.shape.setFillColorAlpha(0.3);
  }
};

/* Initializer */
jQuery(function() {
  q('#mapContainer').moshiMap().init();
  Geofences.init();
  LandmarksView.init();
});
