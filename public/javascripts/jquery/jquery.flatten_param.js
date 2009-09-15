/**
 * == jQuery.flattenParam(map) ==
 *
 * Given a map containing key/value pairs, construct a Rails-style 
 * parameter string. Unlike jQuery.param(), this will traverse any objects
 * within the map and construct "flattened" key/value pairings for them.
 * 
 * The following function call:
 *
 *   jQuery.flattenParam({
 *     order: {
 *       vendor_id: 17,
 *       parts: [{id: 3, count: 7}, {id: 41, count: 2}],
 *       price: 105.60
 *     }
 *   })
 *
 * Produces the following parameter string (url-encoded):
 *   order[vendor_id]=17&
 *   order[parts][][id]=3&
 *   order[parts][][count]=7&
 *   order[parts][][id]=41&
 *   order[parts][][count]=2&
 *   order[price]=105.60
 *
 * Note the structure and order of the [parts] section -- this allows
 * Rails to load the params hash as intended:
 *
 *   params => {:order => {
 *     :vendor_id => 17,
 *     :parts => [
 *       {:id => 3, :count => 7},
 *       {:id => 41, :count => 2}
 *     ],
 *     :price => 105.60
 *   }}
 *
 * As is, this function is not particularly optimized -- expect a slight
 * slowdown on large (or unusually deep) objects.
 *
 * Note that if the map passed in does NOT contain any objects that need
 * traversing, the output will be the same as a call to jQuery.param().
 *
 * @param a map a map of key/value pairs
 */
jQuery.extend({
  flattenParam: function(map) {
    var s = [];
    
    function _flatten(object, prefix) {
      var _prefix;
      if (jQuery.isArray(object)) {
        _prefix = prefix + '[]';
        for(var i = 0; i < object.length; i++) {
          _flatten(object[i], _prefix);
        }
      } else if (typeof object == 'object') {
        for(var key in object) {
          if (prefix == '') {
            _prefix = key;
          } else {
            _prefix = prefix + '[' + key + ']';
          }
          
          _flatten(object[key], _prefix);
        }
      } else {
        var o = {}; o[prefix] = object;
        s[s.length] = jQuery.param(o);
      }
    }
    
    _flatten(map, '');
    return s.join('&');
  }
});