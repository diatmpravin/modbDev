/**
 * Fleet.Frame.Header
 *
 * Represents the header above the resizable frame.
 */
var Fleet = Fleet || {};
Fleet.Frame = Fleet.Frame || {};
Fleet.Frame.Header = (function(Header, Fleet, $) {
  var header,
      headers,
      init = false;
  
  /**
   * init()
   *
   * Create and prepare the header.
   */
  Header.init = function() {
    if (init) {
      return Header;
    }
    
    header = $('#frame_header');
    headers = {};
    
    // The plain ol' header
    headers.standard = 
      $('<div class="standard" style="display:none"><span class="title"></span></div>').appendTo(header);
    
    // A header with Save & Cancel buttons
    headers.edit =
      $('<div class="edit" style="display:none"><span class="title"></span><span class="buttons"></span></div>').appendTo(header);
    
    Header.switch('standard');
    
    init = true;
    return Header;
  };
  
  /**
   * switch(type)
   * switch(type, options)
   *
   * Switch the frame header to the specified type. If provided, the options
   * hash can contain additional options (some are applicable to only certain
   * headers):
   *  title:  a string to display in the header
   *  save:   a callback function for the Save button
   *  cancel: a callback function for the Cancel button
   */
  Header.switch = function(type, options) {
    var newHeader = headers[type];
    
    if (newHeader) {
      // Configure new title, if provided
      if (options && options.title) {
        newHeader.find('span.title').text(options.title);
      } else {
        newHeader.find('span.title').text('');
      }
      
      // Configure new save callback, if provided
      if (options && $.isFunction(options.save)) {
        newHeader.find('button.save')
                 .unbind('.frame_header')
                 .bind('click.frame_header', options.save);
      }
      
      // Configure new cancel callback, if provided
      if (options && $.isFunction(options.cancel)) {
        newHeader.find('button.cancel')
                 .unbind('.frame_header')
                 .bind('click.frame_header', options.cancel);
      }
      
      header.children('div').hide('fast');
      newHeader.show('fast');
    }
    
    return Header;
  };
  
  /**
   * standard(title)
   *
   * A simple shortcut for standard headers. Instead of the normal call:
   *
   *   Header.switch('standard', {title: 'My Page'});
   * 
   * A controller can use the following (shortened) function call:
   *
   *   Header.standard('My Page');
   */
  Header.standard = function(title) {
    return Header.switch('standard', {title: title});
  };
  
  /**
   * edit(title, save, cancel)
   *
   * A simple shortcut for edit headers. Instead of the normal call:
   *
   *  Header.switch('edit', {title: 'Edit', save: func1, cancel: func2});
   *
   * A controller can use the following (shortened) function call:
   *
   *  Header.edit('Edit', func1, func2);
   */
  Header.edit = function(title, save, cancel) {
    return Header.switch('edit', {
      title: title,
      save: save,
      cancel: cancel
    });
  };
  
  /**
   * custom(html, options)
   *
   * Take a block of HTML and a set of options, and create a custom header.
   * This function should probably override the same "custom" div each time,
   * taking care to remove old event handlers?
   */
  Header.custom = function(html, options) {
    // To be implemented as the need arises.
  };
  
  return Header;
}(Fleet.Frame.Header || {}, Fleet, jQuery));
