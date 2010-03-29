/**
 * Data Pane
 */
if (typeof DataPane == 'undefined') { DataPane = {}; };
DataPane.dragging = false;

/**
 * Initialize the "data pane", which contains the group tree and
 * the report card table.
 */
DataPane.init = function() {
  // Allow user to toggle collapsible groups open and closed
  q('div.listing').live('click', function() {
    var self = q(this);
    if (self.closest('li').children('ol').toggle().css('display') == 'none') {
      self.find('span.collapsible').addClass('closed');
    } else {
      self.find('span.collapsible').removeClass('closed');
    }
  });
  
  // Allow user to create groups
  q('a.newGroup').button().live('click', EditPane.Group.newGroup);
  
  // Allow user to edit groups
  q('div.group a.edit').live('click', EditPane.Group.edit);
  
  // Allow user to delete groups
  q('div.group a.delete').live('click', EditPane.Group.confirmRemove);
  
  // Allow user to create devices
  q('a.newDevice').button().live('click', EditPane.Device.newDevice);
  
  // Allow user to edit devices
  q('div.device a.edit').live('click', EditPane.Device.edit);
  
  // Allow user to delete devices
  q('div.device a.delete').live('click', EditPane.Device.confirmRemove);
  
  DataPane.updated('#data_pane');
  
  //q('#frame div.row:first').position().top + q('#frame').offset().top
  // Setup hover tab
  /*q('div.row').hover(function() {
    q('#tab').css('top',q(this).position().top).show();
  }, function() {
    q('#tab').hide();
  });*/
};

/**
 * Setup any fancy events, drag/drops, etc. Will be called when the page is
 * first loaded and whenever an action updates the group tree.
 */
DataPane.updated = function(element) {
  var self = q(element);
  
  // Hide collapsible arrows for empty groups
  self.find('li:not(:has(li)) span.collapsible').hide();
  
  // Allow user to drag groups and vehicles around
  self.find('div.row').draggable({
    helper: 'clone',
    handle: 'div.listing',
    opacity: 0.8,
    distance: 8,
    start: function() { DataPane.dragging = true; },
    stop: function() { DataPane.dragging = false; }
  });
  
  // Allow user to drop groups onto other groups
  self.find('div.group').droppable({
    hoverClass: 'drop-hover',
    greedy: true,
    drop: function(event, ui) {
      if (ui.draggable.hasClass('group')) {
        EditPane.Group.confirmMove(ui.draggable, q(this));
      } else {
        EditPane.Device.confirmMove(ui.draggable, q(this));
      }
    }
  });
};

/**
 * Collapse the data pane, hiding the report card table and showing only
 * the group tree on the left. This allows other panes to be visible on the
 * right.
 */
DataPane.close = function() {
  // "Fix" the width of the report card table so it doesn't resize
  q('#data_pane > ol').css('width', function() { return q(this).width() + 'px'; });
  
  // Collapse the data pane
  q('#data_pane').animate({width:280}, {duration:'normal'});
  
  return this;
};

/**
 * Open the data pane, hiding any existing panes and showing the report card
 * table.
 */
DataPane.open = function() {
  // Open the data pane
  q('#data_pane').animate({width:'100%'}, {
    duration:'normal',
    complete: function() {
      // "Unfix" the width of the report card table so it can be resized
      q('#data_pane > ol').css('width', 'auto');
    }
  });
  
  return this;
};

/* Initializer */
jQuery(DataPane.init);
