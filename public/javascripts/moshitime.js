/**
 * MoshiTime
 *
 * A collection of constants and functions related to time and time zone.
 *
 * Remember: jQuery = q() or $q()!
 */
MoshiTime = {
  difference: 0,
  
  init: function() {
    if (jQuery('#dateTime')) {
      MoshiTime.serverTime = parseInt(jQuery('#dateTimeInternal').html());
      MoshiTime.difference = MoshiTime.serverTime - new Date().getTime();
    }
  }
  ,
  /**
   * Convert a JSON timestamp string into a javascript Date object.
   * Note: ignores any minute portion of a timezone designation.
   *
   * @param  ts an ISO 8601 date time string
   * @return    the corresponding Date object, or undefined
   */
  tsToDate: function(ts) {
    var arr = ts.match(/(\d+)-(\d+)-(\d+)T(\d+):(\d+):(\d+)(\.\d+)?(Z|.+)/);
    if (arr) {
      // Remove the matched string from the front of the array
      arr.shift();
      
      // Convert second fractions into milliseconds
      arr[6] = arr[6] * 1000 || 0;
      
      // Pass all elements into the Date.UTC helper function
      var date = new Date(Date.UTC.apply(this, arr));
      
      // Apply timezone, if necessary
      if (arr[7] != 'Z') {
        date -= arr[7].substring(0,3) * 60 * 60 * 1000
      }
      
      return date;
    }
  }
}

jQuery(function() {
  MoshiTime.init();
});