/**
 * This class handles a pagniated, ajax-ified table view of data.
 * URLs for reading data are pulled from the paginator links.
 * This also has handling for select check_boxes, and keeps track of
 * selections across pages.
 *
 * Takes: parent element that includes .paginator elements and a table
 *
 */
ListView = function(element) {
  var self = this;

  this.element = element;
  this.allSelected = false;
  this.selected = {};

  this.counterDiv = q("#selectedCount");

  q(".pagination a").live("click", function() {
    self.changePage(q(this));
    return false;
  });

  q("input[name=apply_to]").live("click", function() {
    self.elementSelected(this);
  });

  q("#select_all").live("click", function() {
    self.selectAllChecked(this);
  });

  // New page, start out with everything unchecked so
  // as to prevent browser caching from confusing people
  q("input[name=apply_to]").attr('checked', false);

  q.blockUI.defaults.message = "<h1>Please wait ... <img src='/images/spinner.gif'/></h1>";

  this.rebuildHandlers();
}

ListView.prototype = {

  /**
   * Change the page of this list.
   * Takes the link the user clicked on.
   */
  changePage: function(link) {
    var self = this;
    q.ajax({
      type: "GET",
      url: link.attr("href"),
      beforeSend: function() { self.table.block(); },
      complete: function() { self.table.unblock(); },
      success: function(response) {
        self.element.html(response);
        self.rebuildHandlers();
      }
    });
  }
  ,
  /**
   * Retrive a comma-delimited list of all selected ids
   * across all pages.
   */
  getSelected: function() {
    var ids = [];

    q.each(this.selected, function(key, value) {
      if(key.indexOf("apply_to_") == 0) {
        ids.push(value);
      }
    });

    return ids.join(",");
  }
  /**
   * Mark an element locally as checked or unchecked
   */
  ,
  markElement: function(element) {
    var key = element.attr("id");

    if(element.attr("checked")) {
      this.selected[key] = element.val();
    } else {
      delete this.selected[key];
    }
  }
  ,
  /**
   * Update the counter, if one exists, with how many items are selected
   */
  updateCounter: function() {
    if(this.counterDiv.length == 0) { return; }

    var len = 0, key, msg = "";
    for(key in this.selected) {
      if(this.selected.hasOwnProperty(key)) len++;
    }

    if (len > 0) {
      msg = len + " currently selected";
    }

    this.counterDiv.html(msg);
  }
  ,
  selectAllChecked: function(selectAll) {
    var self = this;
    q("input[name=apply_to]", this.table).each(function(idx, element) {
      q(element).attr("checked", q(selectAll).attr("checked"));
      self.markElement(q(element));
    });

    this.updateCounter();
  }
  ,
 /**
  * See if the Select All checkbox on the current page of the list
  * needs to be selected or not.
  */
  updateSelectAll: function() {
    var all = this.table.find("input[name=apply_to]");
    this.selectAll.attr("checked", all.length == all.filter(":checked").length);

    this.updateCounter();
  }
  ,
  elementSelected: function(element) {
    this.markElement(q(element));
    this.updateSelectAll();
  }
  ,
  /**
   * Go through each paginator links and turn them into ajax links.
   * Also, run through the available checkboxes and compare to the selected list
   */
  rebuildHandlers: function() {
    this.table = q("table", this.element);
    this.selectAll = q("#select_all", this.table);

    // Update all boxes on this page to be checked, or not
    q.each(this.selected, function(key, value) {
      q("input#" + key).attr('checked', value);
    });

    // Update the Select All box
    this.updateSelectAll();
  }
};
