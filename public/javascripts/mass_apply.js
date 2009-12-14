/**
 * Generic handling of a Mass Apply form.
 * See /devices/index.html and /devices/index.js for example on
 * how to use this class
 */
MassApply = function(opts) {
  var self = this;

  this.select = q(opts.select);
  this.mapping = opts.mapping || {};
  this.getSelection = opts.getSelection || function() { };

  q(".massApplyForm input.cancel").click(function() { 
    q(this).parents('.massApplyForm').slideUp('fast'); 
  });

  // When a mass apply form is submitted, copy the selection list into the form
  q('.massApplyForm form').submit(function() {
    q(this).find('input[name=apply_ids]').val(self.getSelection());
    return true;
  });

  this.select.val('').change(function() { self.open(); });
}

MassApply.prototype = {
  /**
   * Open the appropriate form according to what was selected
   * in the mass apply drop-down
   */
  open: function() {
    q('.massApplyForm').slideUp('fast');

    var toOpen = this.mapping[this.select.val()];
    if(toOpen) {
      q(toOpen).slideDown('fast');
    }
  }
};
