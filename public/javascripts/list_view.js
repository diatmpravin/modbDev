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
  this.element = element;

  this._processLinks();
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
      success: function(response) {
        self.element.html(response);
        self._processLinks();
      }
    });
  }
  ,
  /**
   * Go through each paginator links and turn them into ajax links
   */
  _processLinks: function() {
    var self = this;

    this.table = q("table", this.element);
    this.paginator = q(".pagination", this.element);

    this.paginator.find("a").click(function() {
      self.changePage(q(this));
      return false;
    });
  }
};
