/**
 * Fleet.Frame.InvoicePane
 *
 * The invoice pane
 *
 */
var Fleet = Fleet || {};
Fleet.Frame = Fleet.Frame || {};
Fleet.Frame.InvoicePane = (function(InvoicePane, Fleet, $) {
  var width = '100%',
      pane,
      list,
      init = false;

  /**
   * init()
   *
   * Create and prepare the InvoicePane
   */
  InvoicePane.init = function() {
    if (init) {
      return InvoicePane;
    }

    // Create the invoice pane
    $('#frame').append('<div id="invoice_pane" class=""><ol></ol></div>');

    // Store a reference to the pane
    pane = $('#invoice_pane');

    // list of invoices
    list = pane.children('ol');

    init = true;
    return InvoicePane;
  };

  /**
   * initPane()
   * initPane(html)
   *
   * populate the pane with content
   */
  InvoicePane.initPane = function(html) {
    //TODO make sure empty html clears up stuff correctly - see reports pane
    list.html(html);

    return InvoicePane;
  };

  /**
   * clearBindings()
   */
  InvoicePane.clearBindings = function() {
  };
  
  /**
   * open()
   * open(callback)
   *
   * Open the invoice pane.  If provided, call the callback after opening
   */
  InvoicePane.open = function(callback) {
    if ($.isFunction(callback)){
      pane.animate({width: width}, {
        duration: 400,
        complete: callback
      });
    } else {
      pane.animate({width: width}, {duration: 400});
    }
    
    return InvoicePane;
  };

  /*
   * close()
   * close(callback)
   *
   * Close the invoice pane.  If provided, call the callback after closing
   */
  InvoicePane.close = function(callback) {
    if ($.isFunction(callback)) {
      pane.animate({width: 0}, {
        duration: 400,
        complete: callback
      });
    } else {
      pane.animate({width: 0}, {duration: 400});
    }
    
    return InvoicePane;
  };
  
  /**
   * width()
   *
   * Return the current width of the invoice pane.
   */
  InvoicePane.width = function() {
    return pane.width();
  };

  return InvoicePane;
}(Fleet.Frame.InvoicePane || {}, Fleet, jQuery));
