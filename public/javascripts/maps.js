/**
 * Moshi
 *
 * A collection of constants for use on the main maps page.
 */
if (typeof Moshi == 'undefined') {
  Moshi = {};
}
Moshi.months = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December'
];
Moshi.weekdays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

/**
 * Maps
 *
 * Scoped variables and functions for the main maps page.
 *
 * Remember: jQuery = q() or $q()!
 */
Maps = {
  // Variables
  devices: [],
  trips: [],
  trip: null,
  tripsByDevice: [],
  tripPoints: 0,
  activity: {},
  today: null,
  historyMonth: null,
  historyDate: null,
  currentPane: '.devices',
  
  // Functions
  init: function() {
    Maps.setToday();
    
    // Event handlers
    q('#device_id').change(Maps.selectDevice);
    
    q('#show_geofences').click(GeofencesView.updateVisibility).attr('checked', false);
    q('#show_landmarks').click(LandmarksView.updateVisibility).attr('checked', false);
    q('#show_labels').click(Maps.toggleLabels).attr('checked', false);
    
    q('#livelook').live('click', Maps.livelook);
    q('#historyScroller li').live('click', Maps.selectHistoryDate)
                            .live('mouseover', Maps.hoverTripSummary)
                            .live('mouseout', Maps.hideTripSummary);
    
    // Prevent crazy flickering when user hovers over the trip summary
    q('#tripSummary').live('mouseover', function() { q(this).show(); })
                     .live('mouseout', function() { q(this).hide(); })
                     .live('click', Maps.selectHistoryDate);
    
    q('#monthBackward').live('click', function() { Maps.adjustHistoryMonth(-1); });
    q('#monthForward').live('click', function() { Maps.adjustHistoryMonth(1); });
    
    // .trip:click is now bound in Trips.init, below
    q('.device:not(.selected)').live('click', Maps.showDeviceInfo);
    q('.device.selected').live('click', Maps.hideDeviceInfo);
    
    q('.device').live('click', Maps.centerDevice);
    
    // Initialize
    q(window).resize(Maps.resize);
    Maps.resize();
    Maps.scrollPane(true);
    Maps.resize();
    
    Maps.buildHistoryScroller();
    Maps.prepareHistoryScroller();
    Maps.getMonthTripData();

    Maps.livelook();
    Maps.corners();
  }
  ,
  buildHistoryScroller: function() {
    var scroller = '';
    
    for(var i = 0; i < 9; i++) { scroller += '<li class="short"></li>'; }
    for(var i = 0; i < 22; i++) { scroller += '<li></li>'; }
    
    q('#historyScroller').append('<ul>' + scroller + '</ul>');
  }
  ,
  prepareHistoryScroller: function() {
    var d = new Date(Maps.historyMonth);
    
    q('#historyScroller li').removeClass('disabled').each(function() {
      var _this = q(this);
      
      _this.data('date', Maps.rubyDateFormat(d));
      _this.data('time', d.getTime());
      
      if (d.getUTCMonth()==Maps.historyMonth.getUTCMonth() && d.getTime() <= Maps.today.getTime()) {
        _this.html(Maps.stringForDate(d));
      } else {
        _this.html('').attr('style', '').addClass('disabled');
      }
      
      d.setUTCDate(d.getUTCDate()+1);
    });
    
    q('#historyMonth span').html(Maps.stringForMonth(Maps.historyMonth));
  }
  ,
  selectDevice: function() {
    var _this = q(this);
    
    if (q('#livelook').hasClass('selected')) {
      Maps.livelook();
      GeofencesView.updateVisibility();
    } else {
      q('#historyScroller li.selected').click();
    }
  }
  ,
  centerDevice: function() {
    var id = q(this).attr('id').match(/device_(.*)/)[1];
    
    for(var i = 0; i < Maps.devices.length; i++) {
      if (Maps.devices[i].device.id == id) {
        var poi = Maps.devices[i].device.poi;
        if (poi) {
          MoshiMap.moshiMap.map.panToLatLng(poi.getLatLng());
        }
      }
    }
  }
  ,
  selectTrip: function(event) {
    if (event.isPropagationStopped()) {
      return;
    }
    
    var _this = q(this);
    
    _this.addClass('selected').find('.additional,.buttons').show()
         .end().siblings('.trip')
         .removeClass('selected').find('.additional,.buttons').hide();
    Maps.scrollPane(false, '.trips');
    
    q.getJSON('/trips/' + _this.attr('id').match(/trip_(.*)/)[1] + ".json", function(json) {
      Maps.trip = json.trip;
      MoshiMap.moshiMap.displayTrip(Maps.trip);
    });
  }
  ,
  showDeviceInfo: function() {
    q(this).addClass('selected').find('.additional').show()
      .end().siblings('.device')
      .removeClass('selected').find('.additional').hide();
  }
  ,
  hideDeviceInfo: function() {
    q(this).removeClass('selected').find('.additional').hide();
  }
  ,
  livelook: function() {
    q('#livelook').addClass('selected');
    q('#historyScroller li').removeClass('selected');
    Maps.historyDate = null;
    
    q('#show_labels').closest('div').show();
    
    Maps.livelookUpdate(function() {
      MoshiMap.moshiMap.bestFit();
    });
  }
  ,
  livelookUpdate: function(callback) {
    if (!q('#livelook').hasClass('selected')) {
      return;
    }
    
    var device_id = q('#device_id').val();
    var jsonURL = (device_id == '' ? '/devices' : '/devices/' + device_id) + ".json";
    var htmlURL = (device_id == '' ? '/maps/status' : '/maps/status?device_id=' + device_id);

    var sel, currentlySelectedId;

    if((sel = q('.devices .device.selected')).length > 0) {
      currentlySelectedId = sel.attr("id").split("_")[1];
    }

    q('.loading').show();
    q.getJSON(jsonURL, function(json) {
      MoshiMap.moshiMap.clearPoints();
      Maps.devices = json;
      
      for(var i = 0; i < Maps.devices.length; i++) {
        var device = Maps.devices[i].device;
        if (device.position != null) {
          var options = {
            icon: device.color.filename.match(/(.*?)\.png/)[1] + '_current.gif',
            size: [21, 21],
            offset: [-10, -10],
            label: device.name
          };
          
          if (!device.connected) {
            options.title = 'As of ' + device.position.time_of_day;
          }
          
          device.poi = MoshiMap.moshiMap.addPoint(device.position, options);
        }
      }
      
      // User may have turned on vehicle labels
      q('#show_labels').change();
      
      if (q.isFunction(callback)) {
        callback();
      }
      
      q.get(htmlURL, function(html) {
        q('#sidebarContent').html(html);
        q('.loading').hide();
        Maps.corners();
        Maps.scrollPane(true, '.devices');

        // Make sure we keep the selected device open
        if(currentlySelectedId) {
          q('.devices #device_' + currentlySelectedId).click();
        }
        
        if (Maps.livelookTimer) { clearTimeout(Maps.livelookTimer); }
        Maps.livelookTimer = setTimeout(Maps.livelookUpdate, 60000);
      }, 'html');
    });
  }
  ,
  selectHistoryDate: function() {
    var _this = q(this);
    
    q('#show_labels').closest('div').hide();
    
    if (_this.data('lastHover')) {
      // User clicked on the trip summary hover
      _this = _this.data('lastHover');
    }
    Maps.historyDate = _this.data('date');
    
    var params = {
      start_date: _this.data('date'),
      end_date: _this.data('date')
    };
    if (q('#device_id').val() != '') {
      params.device_id = q('#device_id').val();
    }
    
    q('#tripSummary').hide();
    q('#livelook').removeClass('selected');
    _this.addClass('selected').siblings('li').removeClass('selected');
    q('#history .loading').show();
    
    q.get('/trips', params, function(html) {
      q('#history .loading').hide();
      q('#sidebarContent').html(html);
      
      Maps.corners();
      Maps.scrollPane(true, '.trips');
      Trips.prepare();
      
      // Display the first trip on the list. If there isn't one,
      // wipe out the currently displayed trip.
      if (q('.trip').length == 0) {
        MoshiMap.moshiMap.pointCollection.removeAll();
      } else {
        q('.trip:first').click();
      }
    });
  }
  ,
  hoverTripSummary: function() {
    if (q(this).hasClass('selected')) {
      return;
    }
    
    var pos = q(this).position();
    var start = q(this).data('time') / 1000;
    var end = start + 24 * 60 * 60;
    
    q('#tripSummary').data('lastHover',
      q(this).addClass('hover').siblings().removeClass('hover').end());
    
    var html = '';
    
    var desiredDevice = q('#device_id').val();
    
    for(var i = 0; i < Maps.devices.length; i++) {
      if (desiredDevice != '' && desiredDevice != Maps.devices[i].device.id) {
        continue;
      }
      
      var trips = Maps.tripsByDevice[Maps.devices[i].device.id];
      if (trips) {
        var num = 0;
        for(var j = 0; j < trips.length; j++) {
          var trip = trips[j];
          if ((trip.start >= start && trip.start < end) ||
            (trip.finish >= start && trip.finish < end) ||
            (trip.start < start && trip.finish >= end)) {
            num++;
          }
        }

        
        if (num > 0) {
          var trips = num > 1 ? 'trips' : 'trip';

          html += '<li><div class="color"><img src="' + trip.color.filename +'" /></div><b>' +
            Maps.devices[i].device.name + '</b><br/><span>' + num + ' ' + trips + '</span></li>';
        }
      }
    }
    
    if (html == '') {
      html = '<li class="empty">No trip activity</li>';
    }
    
    q('#tripSummary ul').html(html)
      .find('li:last').addClass('last'); // last-child hack
    
    q('#tripSummary').css('top', pos.top + 36).css('left', pos.left - 62).show();
  }
  ,
  hideTripSummary: function() {
    var _lastHover = q('#tripSummary').hide().data('lastHover');
    if (_lastHover) {
      _lastHover.removeClass('hover');
    }
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
    Maps.scrollPane(true);
    
    if (MoshiMap.moshiMap) {
      // Introduce an artificial delay to avoid MapQuest resize bugs
      if (Maps.resizeTimer) { clearTimeout(Maps.resizeTimer); }
      Maps.resizeTimer = setTimeout(function() {
        MoshiMap.moshiMap.map.setSize(
          new MQA.Size(_mapContainer.width(), _mapContainer.height())
        );
      }, 500);
    }
  }
  ,
  adjustHistoryMonth: function(delta) {
    Maps.historyMonth.setUTCMonth(Maps.historyMonth.getUTCMonth() + delta);
    Maps.prepareHistoryScroller();
    Maps.getMonthTripData();
    
    q('#historyScroller li').removeClass('selected').each(function() {
      if (q(this).data('date') == Maps.historyDate) {
        q(this).addClass('selected');
      }
    });
    if (Maps.historyMonth.getUTCMonth() == Maps.today.getUTCMonth() &&
        Maps.historyMonth.getUTCFullYear() == Maps.today.getUTCFullYear()) {
      q('#monthForward').hide();
    } else {
      q('#monthForward').show();
    }
  }
  ,
  
  // Utilities and JSON functions
  getMonthTripData: function() {
    var device_id = q('#device_id').val();
    
    var endRange = new Date(Maps.historyMonth);
    endRange.setUTCMonth(endRange.getUTCMonth()+1);
    endRange.setUTCDate(endRange.getUTCDate()-1);
    
    q.getJSON('/trips.json', {
      'start_date': Maps.rubyDateFormat(Maps.historyMonth),
      'end_date': Maps.rubyDateFormat(endRange)
    }, function(json) {
      Maps.trips = json.trips;
      Maps.tripsByDevice = [];
      for(var i = 0; i < Maps.trips.length; i++) {
        var id = Maps.trips[i].device_id;
        Maps.tripsByDevice[id] = Maps.tripsByDevice[id] || [];
        Maps.tripsByDevice[id][Maps.tripsByDevice[id].length] = Maps.trips[i];
      }
    });
  }
  ,
  setToday: function() {
    Maps.today = new Date(MoshiTime.serverTime);
    Maps.historyMonth = new Date(MoshiTime.serverTime);
    Maps.historyMonth.setUTCDate(1);
    Maps.historyMonth.setUTCHours(0);
    Maps.historyMonth.setUTCMinutes(0);
    Maps.historyMonth.setUTCSeconds(0);
  }
  
  ,
  stringForDate: function(date) {
    var weekday = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    return "" + date.getUTCDate() + "<br/><span>" + Moshi.weekdays[date.getUTCDay()] + "</span>";
  }
  ,
  stringForMonth: function(date) {
    if (date.getUTCFullYear() == Maps.today.getUTCFullYear()) {
      return Moshi.months[date.getUTCMonth()];
    } else {
      return "" + Moshi.months[date.getUTCMonth()] + " " + date.getUTCFullYear();
    }
  }
  ,
  prettyTripFormat: function(trip) {
    var date = new Date(trip.start * 1000);
    var m = date.getUTCMinutes(), h = date.getUTCHours();
    var ap = 'am';
    
    if (h > 11) { ap = 'pm' }
    if (h > 12) { h -= 12 }
    if (h == 0) { h = 12 }
    //if (h < 10) { h = '0' + h }
    if (m < 10) { m = '0' + m }
    
    return h + ':' + m + ' ' + ap + ' - ' + trip.miles + ' miles';
  }
  ,
  rubyDateFormat: function(date) {
    var m = date.getUTCMonth() + 1, d = date.getUTCDate(), y = date.getUTCFullYear();
    if (m < 10) { m = '0'+m }
    if (d < 10) { d = '0'+d }
    return m + '/' + d + '/' + y;
  }
  ,
  scrollPane: function(doResize, o) {
    var selector = o;
    if (typeof selector == 'undefined') {
      selector = Maps.currentPane;
    }
    
    if (doResize) {
      var margin = q(selector).position().top - q('#sidebar').position().top;
      var height = q('#sidebar').outerHeight() - 16;
      var newHeight = height - margin;
      q(selector).css('height', newHeight);
    }
    
    Maps.currentPane = selector;
  }
  ,
  toggleLabels: function() {
    var bool = q(this).attr('checked');
    
    for(var i = 0; i < MoshiMap.moshiMap.pointCollection.getSize(); i++) {
      MoshiMap.moshiMap.pointCollection.getAt(i).setValue('labelVisible', bool);
    }
  }
  ,
  corners: function() {
    q('#sidebar, #sidebar h3').corners('transparent');
  }
};

Trips = {
  init: function() {
    q('.trip a.editSettings').live('click', Trips.edit);
    q('.trip a.save').live('click', Trips.save);
    q('.trip a.cancel').live('click', Trips.cancel);
    q('.trip a.add').live('click', Trips.displayForm);
    q('.trip a.remove').live('click', Trips.removeTag);
    q('.trip a.collapse').live('click', Trips.collapse);
    q('.trip a.expand').live('click', Trips.expand);
    
    // Binding this event here to make sure it happens AFTER the
    // expand & collapse functions.
    q('.trip:not(.selected)').live('click', Maps.selectTrip);
    
    q('.trip').live('mouseover', function() {
      q(this).addClass('hover');
    }).live('mouseout', function() {
      q(this).removeClass('hover');
    });
    
    q('#tagDialog input').live('keypress', function(e) {
      // Capture ENTER and submit dialog
      if (e.which == 13) {
        Trips.createTag.call(q('#tagDialog'), e);
      }
    });
    
    q('#tagDialog').dialog({
      title: 'Enter New Tag',
      modal: true,
      autoOpen: false,
      resizable: false,
      buttons: {
        'Add Tag': Trips.createTag,
        'Cancel': function() { q(this).dialog('close'); }
      },
      close: function() { }
    })
    .siblings('.ui-dialog-buttonpane').prepend('<div class="loading"></div>');
  }
  ,
  edit: function() {
    q(this).closest('.view').hide('fast').siblings('.edit').show('fast')
      .closest('.trip').siblings('.trip').hide('fast');
    
    return false;
  }
  ,
  cancel: function() {
    var _edit = q(this).closest('.edit');
    _edit.hide('fast', function() {
      q.get(_edit.find('form').attr('action') + '/edit', function(html) {
        _edit.html(html);
        Trips.prepare(_edit);
      });
    })
    .siblings('.view').show('fast')
    .closest('.trip').siblings('.trip').show('fast');
    
    return false;
  }
  ,
  save: function() {
    var _this = q(this);
    var _edit = _this.closest('div.edit');
    var _view = _edit.siblings('div.view');
    
    _edit.find('form').ajaxSubmit({
      dataType: 'json',
      beforeSubmit: function() { _edit.find('.loading').show(); },
      success: function(json) {
        if (json.status == 'success') {
          q.get(_edit.find('form').attr('action'), function(html) {
            _view.html(html)
                 .find('.additional').show().end()
                 .show('normal')
                 .closest('.trip').siblings('.trip').show('normal');
            _edit.hide('normal', function() {
              q.get(_edit.find('form').attr('action') + '/edit', function(html) {
                _edit.html(html);
                Trips.prepare(_edit);
              });
            });
          });
        } else {
          _edit.html(json.html);
          Trips.prepare(_edit);
        }
      }
    });
    
    return false;
  }
  ,
  displayForm: function() {
    q('#tagDialog').dialog('open')
                   .data('tagList', q(this).closest('ul'));
    return false;
  }
  ,
  collapse: function(event) {
    // We aren't trying to "view" this trip
    event.stopPropagation();
    
    var _this = q(this);
    var _trip = _this.closest('.trip');
    
    _this.closest('form').ajaxSubmit({
      dataType: 'json',
      beforeSubmit: function() { _this.hide('fast').siblings('.loading').show('fast'); },
      success: function(json) {
        if (json.status == 'success') {
          _trip.hide('fast', function() {
            _trip.prev('.trip')
                 .find('div.view').html(json.view).end()
                 .find('div.edit').html(json.edit).end()
                 .removeClass('selected').click();
            _trip.remove();
            
            // After removing a trip, need to correct for alternating styles
            q('.trip:even').removeClass('alternating');
            q('.trip:odd').addClass('alternating');
          });
        } else {
          _this.show('fast').siblings('.loading').hide('fast');
        }
      }
    });
    
    return false;
  }
  ,
  expand: function(event) {
    // We aren't trying to "view" this trip
    event.stopPropagation();
    
    var _this = q(this);
    var _trip = _this.closest('.trip');
    
    _this.closest('form').ajaxSubmit({
      dataType: 'json',
      beforeSubmit: function() { _this.hide('fast').siblings('.loading').show('fast'); },
      success: function(json) {
        if (json.status == 'success') {
          _trip.find('div.view').html(json.view).end()
               .find('div.edit').html(json.edit).end()
               .removeClass('selected').click();
          
          q('<div class="trip section" style="display:none" id="trip_'
            + json.new_trip.id
            + '"><div class="view">'
            + json.new_trip.view
            + '</div><div class="edit">'
            + json.new_trip.edit
            + '</div></div>').insertAfter(_trip).show('fast');
          
          // After adding a trip, need to correct for alternating styles
          q('.trip:even').removeClass('alternating');
          q('.trip:odd').addClass('alternating');
        } else {
          _this.show('fast').siblings('.loading').hide('fast');
        }
      }
    });
    
    return false;
  }
  ,
  createTag: function() {
    var _this = q(this);
    
    _this.find('form').ajaxSubmit({
      dataType: 'json',
      beforeSubmit: function() {
        _this.siblings('.ui-dialog-buttonpane').find('.loading').show();
      },
      success: function(json) {
        _this.siblings('.ui-dialog-buttonpane').find('.loading').hide();
        if (json.status == 'success') {
          Trips.addTag(
            _this.data('tagList'), json.id, json.name
          );
          _this.dialog('close');
        } else {
          _this.errors(json.error);
        }
      }
    });
  }
  ,
  addTag: function(list, id, text) {
    list.find('li:last').before(
      '<li><a href="#" class="remove"></a><span>' + text + '</span>' +
      '<input type="hidden" name="trip[tag_ids][]" value="' +
      id + '" class="id"/></li>'
    );
  }
  ,
  removeTag: function() {
    var _this = q(this);
    var _tag = _this.closest('li');
    var _id = _this.siblings('input.id');
    if (_id.length >= 1) {
      _this.closest('ul').find('select.tagSelect').append(
        '<option value="' + _id.val() + '">' + _tag.find('span').html() + '</option>'
      );
    }
    _tag.hide('normal', function() {
      _tag.remove();
    });
    
    return false;
  }
  ,
  prepare: function(container) {
    if (container) {
      q(container).find('select.tagSelect:not(.evented)').
        change(Trips.select).addClass('evented').val('');
    } else {
      q('div.trips select.tagSelect:not(.evented)').
        change(Trips.select).addClass('evented').val('');
    }
  }
  ,
  select: function() {
    var _this = q(this);
    if (_this.val()=='') {
      return;
    }
    
    var _ul = q(this).closest('ul');    
    Trips.addTag(
      _ul, this.options[this.selectedIndex].value, this.options[this.selectedIndex].text
    );
    
    _this.find('option:selected').remove();
    _this.val('');
  }
};

/* Initializer */
q(function() {
  q('#mapContainer').moshiMap().init();
  Maps.init();
  GeofencesView.init();
  LandmarksView.init();
  Trips.init();
  
  // keeping this around for a little while in case i have to switch to IE7 opacity style
  /*q('#pointWalker .background').attr('style', 'filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(src=\'/images/myimage.png\',sizingMethod=\'scale\')');*/
});
