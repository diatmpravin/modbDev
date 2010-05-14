/**
 * Fleet.Frame.TripPlayerPane
 *
 * Represents the overlay pane the user sees while playing a trip.
 */
var Fleet = Fleet || {};
Fleet.Frame = Fleet.Frame || {};
Fleet.Frame.TripPlayerPane = (function(TripPlayerPane, Fleet, $) {
  var width = 220,
      pane,
      content,
      progress,
      init = false;
  
  /**
   * init()
   *
   * Create and prepare the Geofence Edit pane.
   */
  TripPlayerPane.init = function() {
    if (init) {
      return TripPlayerPane;
    }
    
    // Create the geofence edit pane
    $('#frame').append('<div id="trip_player_pane"><div class="content"></div></div>');
    
    // Store a permanent reference to the pane
    pane = $('#trip_player_pane');
    
    // A reference to our content
    content = pane.children('.content');
    
    // The player progress bar
    progress = $('<div class="progress"></div>').appendTo(pane)
    
	/*<script type="text/javascript">
	$(function() {
		var select = $("#minbeds");
		var slider = $('<div id="slider"></div>').insertAfter(select).slider({
			min: 1,
			max: 6,
			range: "min",
			value: select[0].selectedIndex + 1,
			slide: function(event, ui) {
				select[0].selectedIndex = ui.value - 1;
			}
		});
		$("#minbeds").click(function() {
			slider.slider("value", this.selectedIndex + 1);
		});
	});
	</script>*/
    
    init = true;
    return TripPlayerPane;
  };
  
  /**
   * initPane(html)
   *
   * Replace the pane's content with the given HTML.
   */
  TripPlayerPane.initPane = function(html) {
    if (html) {
      content.html(html);
      
      // Hack - select the ellipse if it's a new geofence
      if ($('#shapeChooser input').val() == '') {
        $('#shapeChooser a:first').addClass('selected');
        $('#shapeChooser input').val(0);
      }
    }
    
    return TripPlayerPane;
  };
  
  /**
   * open()
   *
   * Open the geofence edit pane.
   */
  TripPlayerPane.open = function() {
    pane.animate({opacity: 0.9, right: 8}, {duration: 400});
    
    return TripPlayerPane;
  };
  
  /**
   * close()
   *
   * Close the landmark edit pane.
   */
  TripPlayerPane.close = function() {
    pane.animate({opacity: 0, right: 0 - (width + 8)}, {duration: 400});
    
    return TripPlayerPane;
  };
  
  return TripPlayerPane;
}(Fleet.Frame.TripPlayerPane || {}, Fleet, jQuery));
