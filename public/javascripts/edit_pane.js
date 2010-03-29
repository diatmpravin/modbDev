/**
 * Edit Pane
 */
if (typeof EditPane == 'undefined') { EditPane = {}; }

/**
 * Hide and remove anything currently in the edit pane, then show the
 * loading spinner.
 */
EditPane.clear = function() {
  q('#edit_pane').find('.edit').hide().empty()
                 .siblings('.loading').show();
  
  return this;
},

/**
 * Hide any loading spinner and display whatever is in the edit form.
 */
EditPane.show = function() {
  q('#edit_pane').find('.loading').hide()
                 .siblings('.edit').show();
  
  return this;
},

/**
 * Display an alternate titlebar for the right pane. Calling with null or
 * no parameters will reset the bar to the normal report card display.
 */
EditPane.title = function(newTitle) {
  if (typeof(newTitle) == 'undefined' || newTitle == null) {
    q('#report_card_header div.title').hide('fast');
    q('#report_card_header div.data').show('fast');
  } else {
    q('#report_card_header div.title span').html(newTitle);
    q('#report_card_header div.data').hide('fast');
    q('#report_card_header div.title').show('fast');
  }
  
  return this;
};
