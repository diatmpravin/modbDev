/**
 * Landmarks
 *
 * Constants and functions used on the Landmark Settings page.
 */
Landmarks = {
  landmarkCollection: new MQA.ShapeCollection(),
  
  init: function() {
    Landmarks.landmarkCollection.setName('landmarks');
    MoshiMap.moshiMap.map.addShapeCollection(Landmarks.landmarkCollection);
    
    Landmarks.corners();
    
    q('#show_geofences').change(GeofencesView.updateVisibility).attr('checked', false);
    //q('#show_labels').change(Maps.toggleLabels).attr('checked', false);
    
    q('#addLandmark').live('click', Landmarks.newLandmark);
    q('div.landmark[id=new] input.save').live('click', Landmarks.create);
    q('div.landmark[id=new] input.cancel').live('click', Landmarks.cancelNew);
    
    q('div.landmark[id!=new] input.edit').live('click', Landmarks.edit);
    q('div.landmark[id!=new] input.save').live('click', Landmarks.save);
    q('div.landmark[id!=new] input.cancel').live('click', Landmarks.cancel);
    
    q('div.landmark input.delete').live('click', function() {
      q('#removeLandmark').dialog('open').data('landmark', q(this).closest('div.landmark'));
    });
    
    q('div.landmark[id!=new]').live('mouseover', function() {
      q(this).addClass('hover');
    }).live('mouseout', function() {
      q(this).removeClass('hover');
    });
    
    q('div.landmark input').live('keypress', Landmarks.coordinateEntry);
    
    q("#removeLandmark").dialog({
      title: 'Delete Landmark',
      modal: true,
      autoOpen: false,
      resizable: false,
      width: 450,
      buttons: {
        'Yes, delete this landmark': Landmarks.destroy,
        'No, do not delete': function() { q(this).dialog('close'); }
      }
    });
    
    q(window).resize(Landmarks.resize);
    Landmarks.resize();
    
    Landmarks.buildLandmarks();
  }
  ,
  /**
   * Show the user a new landmark form and associated point on the map.
   */
  newLandmark: function() {
    q('#new').show('fast').siblings('.landmark').hide('fast');
    q('#addLandmark').hide('fast');
    
    var mc = MoshiMap.moshiMap.map.getCenter();
    q('#new').find('input[name$=[latitude]]').attr('value', mc.lat);
    q('#new').find('input[name$=[longitude]]').attr('value', mc.lng);
    
    var tempLandmark = Landmarks.createMapLandmark(q('#new'), true);
    tempLandmark.setValue('draggable', true);
    Landmarks.highlightMapLandmark(tempLandmark);
  }
  ,
  /**
   * Submit a new landmark.
   */
  create: function() {
    var _new = q('#new');
     
    _new.find('form').ajaxSubmit({
      dataType: 'json',
      beforeSubmit: function() { _new.find('.loading').show(); },
      success: function(json) {
        if (json.status == 'success') {
          q('#addLandmark').show('fast');
          _new.hide('fast', function() {
            q(this).clearRailsForm();
          }).siblings('.landmark').show('fast');
          Landmarks.deleteMapLandmark(_new);
          Landmarks.highlightMapLandmark();
          
          var _div = q('<div class="landmark" style="display:none"><div class="view">'
            + json.view
            + '</div><div class="edit">'
            + json.edit
            + '</div></div>').insertAfter('#new').show('fast');
          Landmarks.createMapLandmark(_div);
        } else {
          _new.html(json.html);
        }
      }
    });
  }
  ,
  /**
   * Hide the new landmark form and associated point on the map.
   */
  cancelNew: function() {
    q('#addLandmark').show('fast');
    q('#new').hide('fast', function() {
      q(this).clearRailsForm();
    }).siblings('.landmark').show('fast');
    
    Landmarks.deleteMapLandmark(q('#new'));
    Landmarks.highlightMapLandmark();
  }
  ,
  /**
   * Show the user the edit form for an existing landmark.
   */
  edit: function() {
    q('#addLandmark').hide('fast');
    q(this).closest('div.landmark')
           .siblings('div.landmark').hide('fast').end()
           .find('div.edit').show('fast').end()
           .find('div.view').hide('fast').end()
           .data('point').setValue('draggable', true);
    
    var point = q(this).closest('div.landmark').data('point');
    Landmarks.highlightMapLandmark(point);
    MoshiMap.moshiMap.map.setCenter(point.latLng);
    MoshiMap.moshiMap.map.setZoomLevel(12);
  }
  ,
  /**
   * Submit changes to an existing landmark.
   */
  save: function() {
    var _edit = q(this).closest('div.edit');
    var _landmark = _edit.closest('div.landmark');
    
    _edit.find('form').ajaxSubmit({
      dataType: 'json',
      beforeSubmit: function() { _edit.find('.loading').show(); },
      success: function(json) {
        if (json.status == 'success') {
          q('#addLandmark').show('fast');
          _landmark.siblings('div.landmark[id!=new]').show('fast').end()
                   .find('div.view').html(json.view).show('fast');
          
          _edit.hide('fast', function() {
            _edit.html(json.edit);
            Landmarks.createMapLandmark(_landmark).setValue('draggable', false);
          });
        } else {
          _edit.html(json.html);
        }
      }
    });
    Landmarks.highlightMapLandmark();
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
   * Delete an existing landmark and associated point on the map.
   */
  destroy: function() {
    var _dialog = q(this);
    var _landmark = q(this).data('landmark');
    
    _landmark.find('div.edit form').ajaxSubmit({
      dataType: 'json',
      type: 'DELETE',
      beforeSubmit: function() { _dialog.dialogLoader().show(); },
      complete: function() { _dialog.dialog('close').dialogLoader().hide(); },
      success: function(json) {
        if (json.status == 'success') {
          Landmarks.deleteMapLandmark(_landmark);
          _landmark.hide('fast', function() {
            _landmark.remove();
          });
        } else {
          location.reload();
        }
      }
    });
  }
  ,
  /**
   * Update the point on the map as the user types in the landmark form.
   */
  coordinateEntry: function(e) {
    var _landmark = q(this).closest('div.landmark');
    
    if (Landmarks.coordinateTimer) { clearTimeout(Landmarks.coordinateTimer); }
    Landmarks.coordinateTimer = setTimeout(function() {
      Landmarks.createMapLandmark(_landmark);
    }, 500);
  }
  ,
  corners: function() {
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
  ,
  /**
   * Create points on the map for each landmark and fit them onto the map.
   */
  buildLandmarks: function() {
    Landmarks.landmarks = [];
    
    q('div.landmark[id!=new]').each(function() {
      Landmarks.createMapLandmark(q(this));
    });
    
    var bounds = Landmarks.landmarkCollection.getBoundingRect();
    if (bounds) {
      MoshiMap.moshiMap.map.bestFitLL([bounds.ul, bounds.lr], false, 2, 12);
    }
  }
  ,
  /**
   * Create or update the map point for a landmark container (div).
   */
  createMapLandmark: function(landmarkDiv, temporary) {
    var latitude = landmarkDiv.find('input[name$=[latitude]]').attr('value');
    var longitude = landmarkDiv.find('input[name$=[longitude]]').attr('value');
    var name = landmarkDiv.find('input[name$=[name]]').attr('value');
    
    if (!(latitude && latitude.match(/^[-]?[0-9]+([\.][0-9]+)?$/) &&
          longitude && longitude.match(/^[-]?[0-9]+([\.][0-9]+)?$/))) {
      return;
    }
    
    if (landmarkDiv.data('point')) {
      landmarkDiv.data('point').setValue('latLng', new MQA.LatLng(latitude, longitude));
      landmarkDiv.data('point').setValue('infoTitleHTML', name);
      
      return landmarkDiv.data('point');
    } else {
      var point = new MQA.Poi(new MQA.LatLng(latitude, longitude));
      
      point.setValue('icon', new MQA.Icon('/images/landmark.png', 24, 24));
      point.setValue('iconOffset', new MQA.Point(-12, -21));
      point.setValue('shadow', new MQA.Icon('/images/blank.gif'));
      point.setValue('altIcon', new MQA.Icon('/images/landmark_faded.png', 24, 24));
      point.setValue('altIconOffset', new MQA.Point(-12, -21));
      point.setValue('altShadow', new MQA.Icon('/images/blank.gif'));
      point.setValue('rolloverEnabled', true);
      point.setValue('keepRolloverOnDrag', false);
      point.setValue('infoTitleHTML', name);
      
      MQA.EventManager.addListener(point, 'mouseup', Landmarks.updateLandmarkFromMap);
      
      Landmarks.landmarkCollection.add(point);
      
      landmarkDiv.data('point', point);
      point.landmark = landmarkDiv;
      
      return point;
    }
  }
  ,
  /**
   * Delete the map point associated with the given landmark container (div).
   */
  deleteMapLandmark: function(landmarkDiv) {
    var point = landmarkDiv.data('point');
    
    if (point) {
      MQA.EventManager.clearListeners(point, 'mouseup');
      
      Landmarks.landmarkCollection.removeItem(point);
      landmarkDiv.removeData('point');
    }
  }
  ,
  /**
   * Update the landmark form as the user drags the point on the map.
   */
  updateLandmarkFromMap: function(mqEvent) {
    if (this.landmark) {
      this.landmark.find('input[name$=[latitude]]').attr('value', this.latLng.lat).end()
                   .find('input[name$=[longitude]]').attr('value', this.latLng.lng);
    }
  }
  ,
  /**
   * Highlight the given landmark by "fading" all the others.
   *
   * If no parameter is given, reset all landmarks to normal icons.
   */
  highlightMapLandmark: function(landmark) {
    var n = Landmarks.landmarkCollection.getSize();
    
    if (landmark) {
      for(var i = 0; i < n; i++) {
        Landmarks.landmarkCollection.getAt(i).setValue('altStateFlag', true);
      }
      landmark.setValue('altStateFlag', false);
    } else {
      for(var i = 0; i < n; i++) {
        Landmarks.landmarkCollection.getAt(i).setValue('altStateFlag', false);
      }
    }
  }
};

/* Initializer */
jQuery(function() {
  q('#mapContainer').moshiMap().init();
  Landmarks.init();
  GeofencesView.init();
});
