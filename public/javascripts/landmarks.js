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
  newLandmark: function() {
    q('#new').show('fast').siblings('.landmark').hide('fast');
    q('#addLandmark').hide('fast');
    
    //Landmarks.enterMode();
  }
  ,
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
          
          q('<div class="landmark" style="display:none"><div class="view">'
            + json.view
            + '</div><div class="edit">'
            + json.edit
            + '</div></div>').insertAfter('#new').show('fast');
        } else {
          _new.html(json.html);
        }
      }
    });
  }
  ,
  cancelNew: function() {
    q('#addLandmark').show('fast');
    q('#new').hide('fast', function() {
      q(this).clearRailsForm();
    }).siblings('.landmark').show('fast');
    
    // Landmarks.exitMode();
  }
  ,
  edit: function() {
    q('#addLandmark').hide('fast');
    q(this).closest('div.landmark')
           .siblings('div.landmark').hide('fast').end()
           .find('div.edit').show('fast').end()
           .find('div.view').hide('fast').end()
           .data('point').setValue('draggable', true);
  }
  ,
  save: function() {
    var _edit = q(this).closest('div.edit');
    
    _edit.find('form').ajaxSubmit({
      dataType: 'json',
      beforeSubmit: function() { _edit.find('.loading').show(); },
      success: function(json) {
        if (json.status == 'success') {
          q('#addLandmark').show('fast');
          _edit.siblings('div.view').html(json.view).show('fast')
               .closest('div.landmark')
               .siblings('div.landmark[id!=new]').show('fast');
          
          _edit.hide('fast', function() {
            _edit.html(json.edit);
          });
        } else {
          _edit.html(json.html);
        }
      }
    });
  }
  ,
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
  }
  ,
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
          if (_landmark.data('point')) {
            MoshiMap.moshiMap.pointCollection.removeItem(_landmark.data('point'));
          }
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
  buildLandmarks: function() {
    Landmarks.landmarks = [];
    
    q('div.landmark[id!=new]').each(function() {
      Landmarks.createMapLandmark(q(this));
    });
    
    var bounds = MoshiMap.moshiMap.pointCollection.getBoundingRect();
    if (bounds) {
      MoshiMap.moshiMap.map.bestFitLL([bounds.ul, bounds.lr]);
    }
  }
  ,
  createMapLandmark: function(landmarkDiv) {
    var latitude = landmarkDiv.find('input[name$=[latitude]]').attr('value');
    var longitude = landmarkDiv.find('input[name$=[longitude]]').attr('value');
    
    if (!(latitude && latitude.match(/^[-]?[0-9]+([\.][0-9]+)?$/) &&
          longitude && longitude.match(/^[-]?[0-9]+([\.][0-9]+)?$/))) {
      return;
    }
    
    if (landmarkDiv.data('point')) {
      landmarkDiv.data('point').setValue('latLng', new MQA.LatLng(latitude, longitude));
      
      return landmarkDiv.data('point');
    } else {
      var point = new MQA.Poi(new MQA.LatLng(latitude, longitude));
      
      point.setValue('shadow', new MQA.Icon('/images/blank.gif'));
      point.setValue('rolloverEnabled', true);
      point.setValue('infoTitleHTML', landmarkDiv.find('input[name$=[name]]').attr('value'));
      
      MQA.EventManager.addListener(point, 'mouseup', Landmarks.updateLandmarkFromMap);
      
      MoshiMap.moshiMap.pointCollection.add(point);
      landmarkDiv.data('point', point);
      point.landmark = landmarkDiv;
      
      return point;
    }
  }
  ,
  updateLandmarkFromMap: function(mqEvent) {
    if (this.landmark) {
      this.landmark.find('input[name$=[latitude]]').attr('value', this.latLng.lat).end()
                   .find('input[name$=[longitude]]').attr('value', this.latLng.lng);
    }
  }
};

/*
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
    };*/

/* Initializer */
jQuery(function() {
  q('#mapContainer').moshiMap().init();
  Landmarks.init();
});
