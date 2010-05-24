/**
 * Fleet.BillingController
 *
 * Billing Controller
 */
var Fleet = Fleet || {};
Fleet.BillingController = (function(BillingController, InvoicePane, Header, Frame, $) {
  var invoicesHtml = null,
      init = false;

  /* Billing Tab */
  BillingController.tab = 'billing';

  /**
   * init()
   */
  BillingController.init = function () {
    if (init) {
      return BillingController;
    }

    // define the billing header
    Header.init().define('billing',
      '<span class="title">Billing</span>' +
      '<div class="billing_data">'+
      '<span class="amount"><span>Amount</span></span>' +
      '<span class="date_due"><span>Date Due</span></span>' +
      '<span class="trackers"><span>Trackers</span></span>' +
      '<span class="paid"><span>Paid</span></span>' +
      '</div>');

    init=true;
  };


  /**
   * setup()
   *
   * Prepare panes
   */
  BillingController.setup = function() {
    Header.init().open('billing');

    InvoicePane.init().open();
    
    BillingController.refresh();
  };

  /**
   * teardown()
   *
   * Hide panes and throw out stuff
   */
  BillingController.teardown = function() {
    InvoicePane.close().initPane('');
    Header.standard('');
    invoicesHtml = null;
  };

  function loading(bool) {
    Frame.loading(bool);
    Header.loading(bool);
  }

  /**
   * refresh()
   *
   */
  BillingController.refresh = function() {
    // get the invoices html
    $.get ('/invoices', function(html) {
      invoicesHtml = html;
      InvoicePane.initPane(invoicesHtml);
    });
  };

  return BillingController;
}(Fleet.BillingController || {},
  Fleet.Frame.InvoicePane,
  Fleet.Frame.Header,
  Fleet.Frame,
  jQuery));
