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
    
    q('div.landmark[id!=new]').live('mouseover', function() {
      q(this).addClass('hover');
    }).live('mouseout', function() {
      q(this).removeClass('hover');
    });
    
    q(window).resize(Landmarks.resize);
    Landmarks.resize();
    
    //Landmarks.buildLandmarks();
  }
  ,
  newLandmark: function() {
    q('#new').show('fast').siblings('.landmark').hide('fast');
    q('#addLandmark').hide('fast');
    
    //Landmarks.enterMode();
    
    return false;
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
    
    return false;
  }
  ,
  edit: function() {
    q('#addLandmark').hide('fast');
    q(this).closest('div.landmark')
           .siblings('div.landmark').hide('fast').end()
           .find('div.edit').show('fast').end()
           .find('div.view').hide('fast');
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
    
    q('#addLandmark').show('fast');
    _edit.closest('div.landmark')
         .siblings('div.landmark[id!=new]').show('fast').end()
         .find('div.view').show('fast').end()
         .find('div.edit').hide('fast', function() {
           q.get(_edit.find('form').attr('action') + '/edit', function(html) {
             _edit.html(html);
           });
         });
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
