/**
 * /devices/live_look page. Given a set of devices, show a map
 * and show the devices on the map.
 */

LiveLook = {
  /** Keep track of the map object */
  map: null
  ,
  /** List of devices we're tracking */
  devices: []
  ,
  init: function() {
    LiveLook.map = new Map.View({contentWidth: 1});

    LiveLook.updatePath = "/devices/live_look?device_ids=" + q("#device_ids").val();
    LiveLook.devices = q("#device_ids").val().split(",");

    LiveLook.updateDevices(function() {
      LiveLook.map.bestFit();
    });
  }
  ,
  /**
   * Run json request for current position of tracking devices
   */
  updateDevices: function(callback) {
    q.getJSON(LiveLook.updatePath, function(devices) {
      var device, options, i;

      LiveLook.map.removePoints();

      for(i = 0; i < devices.length; i++) {
        device = devices[i].device;
        if (device.position != null) {
          options = {
            icon: device.color.filename.match(/(.*?)\.png/)[1] + '_current.gif',
            size: [21, 21],
            offset: [-10, -10],
            label: device.name
          };
          
          options.title = device.name;
          
          if (!device.connected) {
            options.description = 'As of ' + device.position.time_of_day;
          }
          
          LiveLook.map.addPoint(device.position, options);
        }
      }

      if(q.isFunction(callback)) {
        callback();
      }

      setTimeout(LiveLook.updateDevices, 60000);
    });
  }

};

jQuery(LiveLook.init);
